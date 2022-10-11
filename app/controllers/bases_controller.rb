class BasesController < ApplicationController
  
  def new
    @base = Base.new
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "新規作成しました。"
      redirect_to bases_url
    else
      render :new
    end
  end
  
  def index
    @bases = Base.all
  end

  def edit
  end

  private
  
    def base_params
      params.require(:base).permit(:name, :base_number, :attendance_type)
    end
end
