class DevicesController < ApplicationController

  before_filter { params[:application_id] && @application = Application.find(params[:application_id].to_i) }

  def show
    @device = Device.find(params[:id])
    @notifications = @device.notifications.includes(:auth_key => :environment).asc.page(params[:page])
  end
  def index
    @devices = @application.devices.asc.page(params[:page])
  end
end
