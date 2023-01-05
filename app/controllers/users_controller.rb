class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :edit_user_info, :update_user_info, :destroy]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :edit_user_info, :update_user_info, :destroy]
  before_action :set_one_month, only: :show

  def index
    @users = User.where.not(id:1)
  end

  def import
    User.import(params[:file])
    redirect_to users_url
  end
 
  def show
    if current_user.admin?
      redirect_to root_url
    end
    @worked_sum = @attendances.where.not(started_at: nil).count
    @attendance = @user.attendances.find_by(worked_on: @first_day)
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @req_overtime_quantity = Attendance.where(overtime_request_status: "申請中", confirmer: @user.name).count
    @req_onemonth_quantity = Attendance.where(onemonth_request_status: "申請中", onemonth_confirmer: @user.name).count
    @req_attendance_change_quantity = Attendance.where(attendance_change_request_status: "申請中", attendance_change_confirmer: @user.name).count
  
    # csv出力
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_attendances_csv(@attendances)
      end
    end
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "新規作成しました。"
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to users_url
    else
      render:edit
    end
  end

  def edit_user_info
  end

  def update_user_info
    if @user.update_attributes(user_info_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to users_url
    else
      render:index
    end
  end

  def working_list
    # 条件に合致する勤怠データを絞ってからuserと関連づける。
    @in_attendances = Attendance.where(worked_on: Date.current)
                         .where(finished_at: nil)
                         .where.not(started_at: nil)
                         .includes(:user)
  end
  
  def edit_basic_info
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  private
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end

    def user_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid,
                                   :basic_work_time, :designated_work_start_time, :designated_work_end_time,
                                   :password, :password_confirmation)
    end

    def send_attendances_csv(attendances)
      #文字化け防止
      bom = "\uFEFF"
      # CSV.generateとは、対象データを自動的にCSV形式に変換してくれるCSVライブラリの一種
      csv_data = CSV.generate do |csv|
        # %w()は、空白で区切って配列を返します
        header = %w(日付 出勤時間 退勤時間)
        # csv << column_namesは表の列に入る名前を定義します。
        csv << header
        # column_valuesに代入するカラム値を定義します。
        attendances.each do |day|
          column_values = [
            day.worked_on.strftime("%Y年%m月%d日(#{$days_of_the_week[day.worked_on.wday]})"),
            if day.started_at.present? && (day.attendance_change_request_status == "承認").present?
              l(day.started_at, format: :time)
            else
              nil
            end,
            if day.finished_at.present? && (day.attendance_change_request_status == "承認").present?
              l(day.finished_at, format: :time)
            else
              nil
            end
          ]
        # csv << column_valuesは表の行に入る値を定義します。
          csv << column_values
        end
      end
      # csv出力のファイル名を定義します。
      send_data(csv_data, filename: "勤怠一覧.csv")
    end
end