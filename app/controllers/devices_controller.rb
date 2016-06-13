class DevicesController < ApplicationController

  before_filter { @application = Application.find(params[:application_id].to_i) }
  before_filter { params[:id] && @notification = @application.notifications.find(params[:id].to_i) }

  def show
    @device = Device.find(params[:id])
    @notifications = @device.notifications.includes(:auth_key => :environment).asc.page(params[:page])
  end
  def index
    @devices = @application.devices.asc.includes(:auth_key => :environment).page(params[:page])
  end
end
