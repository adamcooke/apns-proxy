class DevicesController < ApplicationController

  def show
    @device = Device.find(params[:id])
    @notifications = @device.notifications.includes(:auth_key => :environment).asc.page(params[:page])
  end

end
