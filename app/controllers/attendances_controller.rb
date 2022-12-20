class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :notice_overtime, :update_approve_req_overtime]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month 
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month
  end

  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.attributes = item #ここでオブジェクトのカラム全体を更新(この時点ではレコードに保存していない)
        attendance.save!(context: :update_one_month) #ここで↑で更新した値をレコードに保存(同時にバリデーションを実行)
      end
    end
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  # 残業申請フォーム
  def request_overtime
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end

  # 残業申請送信
  def update_request_overtime
    @user = User.find(params[:user_id])
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      request_overtime_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.overtime_request_status = "申請中"
        attendance.attributes = item #ここでオブジェクトのカラム全体を更新(この時点ではレコードに保存していない)
        attendance.save!(context: :update_request_overtime) # 入力項目のバリデーション実行
      end
    end
    flash[:success] = "残業を申請しました。"
    redirect_to user_url(current_user)

  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "入力が足りません。やり直してください。"
    redirect_to user_url(current_user)

  end

  # 残業申請のお知らせモーダル
  def notice_overtime
    @attendance_lists = Attendance.where(overtime_request_status: "申請中", confirmer: @user.name)
                                  .order(:worked_on).group_by(&:user_id)
    @request_users = User.where(id: Attendance.where(confirmer: @user.name, overtime_request_status: "申請中").select(:user_id))
  end

  # 残業申請の承認
  def update_approve_req_overtime
    if Attendance.finish_at_update(@user.designated_work_end_time, notice_overtime_params)
      flash[:success] = "変更を送信しました。"
    else
      flash[:danger] = "変更に失敗しました。やり直してください。"
    end
    redirect_to user_url(current_user)
  end

  # １ヶ月の勤怠の申請
  def request_onemonth
    @user = User.find(params[:user_id])
    @month_attendance = @user.attendances.find_by(worked_on: params[:attendance][:day])
    if request_onemonth_params[:onemonth_confirmer].present? 
      @month_attendance.update(request_onemonth_params)
      flash[:success] = "#{@user.name}の1か月分の申請をしました。"
    else
      flash[:danger]= "所属長を選択してください。"
    end
    redirect_to user_url(@user)  
  end

  # １ヶ月の勤怠の承認
  def update_approve_req_onemonth

  end
  

  private
    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end

    # 残業申請情報
    def request_overtime_params
      params.require(:user).permit(attendances: [:worked_on, :end_time, :nextday, :overtime_reason, :confirmer, :overtime_request_status])[:attendances]
    end

    # 残業申請の承認情報
    def notice_overtime_params
      params.require(:user).permit(attendances: [:overtime_request_status, :approval])[:attendances]
    end

    # １ヶ月の勤怠申請情報
      def request_onemonth_params
        params.require(:user).permit(attendances: [:onemonth_confirmer])[:attendances]
      end
end