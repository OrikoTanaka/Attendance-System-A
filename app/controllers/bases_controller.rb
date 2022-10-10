class BasesController < ApplicationController
  def index
    @bases = Base.all
  end

  def edit
  end
end
