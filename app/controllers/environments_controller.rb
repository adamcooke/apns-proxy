class EnvironmentsController < ApplicationController
  
  before_filter { @application = Application.find(params[:application_id].to_i) }
  before_filter { params[:id] && @environment = @application.environments.find(params[:id].to_i) }
  
  def new
    @environment = @application.environments.build
  end
  
  def create
    @environment = @application.environments.build(permitted_params)
    if @environment.save
      redirect_to @application, :notice => "Environment created successfully"
    else
      render :action => "new"
    end
  end
  
  def update
    if @environment.update_attributes(permitted_params)
      redirect_to @application, :notice => "Environment updated successfully"
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @environment.destroy
    redirect_to @application, :notice => "Environment deleted successfully"
  end
  
  private
  
  def permitted_params
    params.require(:environment).permit(:name, :certificate)
  end
  
end
