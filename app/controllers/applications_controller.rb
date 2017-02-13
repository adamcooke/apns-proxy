class ApplicationsController < ApplicationController

  before_filter { params[:id] && @application = Application.find(params[:id].to_i) }

  def index
    @applications = Application.asc
  end

  def show
    @environments = @application.environments.asc
    @auth_keys = @application.auth_keys.asc.includes(:environment)
  end

  def new
    @application = Application.new
  end

  def create
    @application = Application.new(permitted_params)
    if @application.save
      redirect_to @application, :notice => "Application created successfully"
    else
      render :action => "new"
    end
  end

  def update
    if @application.update_attributes(permitted_params)
      redirect_to @application, :notice => "Application updated successfully"
    else
      render :action => "edit"
    end
  end

  def destroy
    @application.destroy
    redirect_to :applications, :notice => "Application deleted successfully"
  end

  private

  def permitted_params
    params.require(:application).permit(:name)
  end

end
