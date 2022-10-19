class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :edit_user_info, :update_user_info, :destroy]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :edit_user_info, :update_user_info, :destroy]
  before_action :set_one_month, only: :show

  def index
    @users = User.all
  end

  def import
    User.import(params[:file])
    redirect_to users_url
  end
 
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
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
end