class BasesController < ApplicationController
  before_action :set_base, only: [:edit_bases_info, :update_bases_info, :destroy]

  def new
    @base = Base.new
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "新規作成しました。"
      redirect_to bases_url
    else
      render :index
    end
  end
  
  def index
    @bases = Base.all
    @base = Base.new
  end

  def edit
  end

  def edit_bases_info
  end

  def update_bases_info
    if @base.update_attributes(base_params)
      flash[:success] = "#{@base.name}の情報を更新しました。"
    else
      flash[:danger] = "#{@base.name}の更新は失敗しました。<br>" + @base.errors.full_messages.join("<br>")
    end
    redirect_to bases_url
  end

  def destroy
  end

  private
  
    def base_params
      params.require(:base).permit(:name, :base_number, :attendance_type)
    end

    # beforeフィルター
    def set_base
      @base = Base.find(params[:id])
    end
end
