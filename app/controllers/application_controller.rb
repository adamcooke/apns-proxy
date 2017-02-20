class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :login_required

  private

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) || :false
  end

  def current_user=(user)
    if user.is_a?(User)
      session[:user_id] = user.id
      @current_user = user
    end
  end

  def logged_in?
    current_user.is_a?(User)
  end

  def login_required
    unless logged_in?
      redirect_to login_path
    end
  end

  helper_method :logged_in?, :current_user

end
