class NotificationsController < ApplicationController

  before_filter { @application = Application.find(params[:application_id].to_i) }
  before_filter { params[:id] && @notification = @application.notifications.find(params[:id].to_i) }

  def index
    @notifications = @application.notifications.asc.includes(:auth_key => :environment).page(params[:page])
  end

  def resend
    new_notification = @notification.resend
    redirect_to [@application, new_notification]
  end

end
