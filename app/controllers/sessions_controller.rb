class SessionsController < ApplicationController

  skip_before_action :login_required
  skip_before_action :require_two_factor_auth

  def create
    if user = User.authenticate(params[:username], params[:password], request.ip)
      self.current_user = user
      redirect_to root_path
    else
      flash.now[:alert] = "The username/password you have entered is incorrect."
      render :action => "new"
    end
  rescue LogLogins::LoginBlocked
    flash.now[:alert] = "Login attempts have been blocked due to too many failed login attempts."
    render :action => "new"
  end

  def destroy
    reset_session
    auth_session.invalidate!
    redirect_to login_path, :notice => "You have been logged out"
  end

end
