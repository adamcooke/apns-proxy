class ApiController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_before_action :login_required

  before_action :parse_json_payload
  before_action :find_auth_key, :only => [:notify, :register]
  before_action :find_application_api_key, :only => [:add_auth_key, :remove_auth_key]

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
    if device.nil?
      device = @auth_key.devices.build(:token => @payload[:device])
    end
    device.label = @payload[:label] if @payload.keys.include?('label')
    device.last_registered_at = Time.now
    device.unsubscribed_at = nil
    if device.save
      json({:status => 'ok', :device => device ? device.id : nil}, 200)
    else
      json({:errors => device.errors}, 422)
    end
  end

  def add_auth_key
    auth_key = @application.auth_keys.build
    auth_key.name = @payload['name']
    auth_key.environment = @application.environments.where(:name => @payload['environment']).first
    if auth_key.save
      json({:status => 'ok', :key => auth_key.key})
    else
      json({:errors => auth_key.errors}, 422)
    end
  end

  def remove_auth_key
    auth_keys = @application.auth_keys.where(:key => @payload['key']).destroy_all
    json({:status => 'ok', :keys_removed => auth_keys.size})
  end

  private

  def json(object, status = 200)
    render :json => object, :status => status
  end

  def parse_json_payload
    begin
      @payload = JSON.parse(request.body.read).with_indifferent_access
    rescue
      json({:error => 'Invalid json payload'}, 400)
    end
  end

  def find_auth_key
    @auth_key = AuthKey.find_by_key(@payload[:auth_key])
    if @auth_key.nil?
      json({:error => 'Access denied'}, 403)
    end
  end

  def find_application_api_key
    if @payload[:api_key].present?
      @application = Application.find_by_api_key(@payload[:api_key])
      if @application.nil?
        json({:error => 'Invalid application API key'}, 403)
      end
    else
      json({:error => 'Missing application API key'}, 403)
    end
  end

end
