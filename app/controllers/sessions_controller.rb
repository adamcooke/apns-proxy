class SessionsController < ApplicationController

  skip_before_action :login_required

  def create
    if self.current_user = User.authenticate(params[:username], params[:password])
      redirect_to root_path
    else
      flash.now[:alert] = "The username/password you have entered is incorrect."
      render :action => "new"
    end
  end

  def destroy
    reset_session
    redirect_to login_path, :notice => "You have been logged out"
  end

end
