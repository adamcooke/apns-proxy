class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_authorized_network
  before_action :login_required
  before_action :require_two_factor_auth

  rescue_from AuthorizedNetworks::UnauthorizedNetworkError, :with => :unauthorized_network

  private

  def login_required
    unless logged_in?
      redirect_to login_path
    end
  end

  helper_method :logged_in?, :current_user

  def unauthorized_network
    render :plain => "Not permitted", :Status => 403
  end

end
