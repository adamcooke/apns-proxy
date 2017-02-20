class AuthKeysController < ApplicationController

  before_action { @application = Application.find(params[:application_id].to_i) }
  before_action { params[:id] && @auth_key = @application.auth_keys.find(params[:id].to_i) }

  def new
    @auth_key = @application.auth_keys.build
  end

  def create
    @auth_key = @application.auth_keys.build(permitted_params)
    if @auth_key.save
      redirect_to @application, :notice => "Auth Key created successfully"
    else
      render :action => "new"
    end
  end

  def update
    if @auth_key.update_attributes(permitted_params)
      redirect_to @application, :notice => "Auth Key updated successfully"
    else
      render :action => "edit"
    end
  end

  def destroy
    @auth_key.destroy
    redirect_to @application, :notice => "Auth Key deleted successfully"
  end

  private

  def permitted_params
    params.require(:auth_key).permit(:name, :key, :environment_id)
  end

end
