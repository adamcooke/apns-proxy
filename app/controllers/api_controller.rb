class ApiController < ApplicationController
  
  class Error < StandardError; end
  
  rescue_from Error, :with => :handle_error
  skip_before_filter :verify_authenticity_token
  skip_before_filter :login_required
  
  before_filter do
    begin
      @payload = JSON.parse(request.body.read).with_indifferent_access
    rescue
      raise Error, "`payload` could not be parsed as JSON"
    end
    @auth_key = AuthKey.find_by_key(@payload[:auth_key]) || raise(Error, "auth_key is invalid")
  end
  
  def notify
    notification = Notification.build_from_payload(@auth_key, @payload)
    if notification.save
      json(notification.to_hash, 201)
    else
      json({:errors => notification.errors}, 422)
    end
  end
  
  def register
    device = @auth_key.devices.where(:token => @payload[:device]).first
    if device
      device.last_registered_at = Time.now
      device.save!
    end
    json({:status => 'ok', :device => device ? device.id : nil})
  end
  
  private
  
  def json(object, status = 200)
    render :json => object, :status => status
  end
  
  def handle_error(error)
    json :error => error.message, :status => 400
  end
  
end
