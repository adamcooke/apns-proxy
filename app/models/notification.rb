# == Schema Information
#
# Table name: notifications
#
#  id                :integer          not null, primary key
#  auth_key_id       :integer
#  device_id         :integer
#  pushed_at         :datetime
#  created_at        :datetime
#  alert_body        :string(255)
#  action_loc_key    :string(255)
#  loc_key           :string(255)
#  loc_args          :text
#  launch_image      :string(255)
#  badge             :integer
#  sound             :string(255)
#  content_available :boolean
#  custom_data       :text
#  error_code        :integer
#

class Notification < ActiveRecord::Base
  
  belongs_to :auth_key
  belongs_to :device
  
  validate do
    if !has_alert? && self.sound.nil? && self.badge.nil?
      errors.add :alert, "missing"
      errors.add :sound, "missing"
      errors.add :badge, "missing"
    end
    
    if device.unsubscribed?
      errors.add :device, "unsubscribed"
    end
  end
  
  scope :asc, -> { order(:id => :desc) }
  scope :requires_pushing, -> { where(:pushed_at => nil, :error_code => nil).order(:id) }
  
  #
  # Has this been pushed?
  #
  def pushed?
    !!self.pushed_at
  end
  
  #
  # Mark as resendable
  #
  def mark_as_repushable!
    self.pushed_at = nil
    self.error_code = nil
    self.save!
  end
  
  #
  # Mark this notification as pushed
  #
  def mark_as_pushed!
    self.pushed_at = Time.now
    self.save!
  end
  
  #
  # Mark this notification as failed
  #
  def mark_as_failed!(error_code)
    self.error_code = error_code
    self.save!
  end
  
  #
  # Return a description
  #
  def description
    Array.new.tap do |s|
      
      if has_alert?
        s << "send alert '#{self.alert_body || self.loc_key}'"
      end
      
      if has_sound?
        s << "play sound #{self.sound}"
      end
      
      if has_badge?
        s << "set badge to #{self.badge}"
      end
      
    end.to_sentence.capitalize
  end
  
  
  #
  # Should the alert be presented as a Hash?
  #
  # This is the case if we have any of the additional alert properties for this
  # notification.
  #
  def present_alert_as_hash?
    !!(self.action_loc_key || self.loc_key || self.loc_args || self.launch_image)
  end
  
  #
  # Does this have an alert associated?
  #
  def has_alert?
    present_alert_as_hash? || self.alert_body
  end
  
  #
  # Does this have a sound
  #
  def has_sound?
    !!self.sound
  end
  
  #
  # Does this have a badge?
  #
  def has_badge?
    !!self.badge
  end
  
  #
  # Return a JSON hash for this notification
  #
  def to_hash
    Hash.new.tap do |h|
      h[:id] = self.id
      h[:device] = self.device.token
      h[:pushed_at] = self.pushed_at
      h[:created_at] = self.created_at
      
      h[:notification] = {}
      h[:notification][:sound] = self.sound if self.sound
      h[:notification][:badge] = self.badge if self.badge
      
      if self.has_alert?
        h[:notification][:alert] = {}
        h[:notification][:alert][:body] = self.alert_body                 if self.alert_body
        h[:notification][:alert][:action_loc_key] = self.action_loc_key   if self.action_loc_key
        h[:notification][:alert][:loc_key] = self.loc_key                 if self.loc_key
        h[:notification][:alert][:loc_args] = JSON.parse(self.loc_args)   if self.loc_args
        h[:notification][:alert][:launch_image] = self.launch_image       if self.launch_image
      end
      
      h[:notification][:custom_data] = JSON.parse(self.custom_data)     if self.custom_data
    end
  end
  
  # 
  # Return notification as Houston Notification object
  #
  def to_houston_notification
    n = Houston::Notification.new(:device => self.device.token)
    n.id = self.id
    
    if has_alert?
      if present_alert_as_hash?
        n.alert = {}
        n.alert['body'] = self.alert_body                 if self.alert_body
        n.alert['action-loc-key'] = self.action_loc_key   if self.action_loc_key
        n.alert['loc-key'] = self.loc_key                 if self.loc_key
        n.alert['loc-args'] = JSON.parse(self.loc_args)   if self.loc_args
        n.alert['launch-image'] = self.launch_image       if self.launch_image
      else
        n.alert = self.alert_body
      end
    end
    
    if has_sound?
      n.sound = self.sound
    end
    
    if has_badge?
      n.badge = self.badge
    end
    
    unless n.content_available.nil?
      n.content_available = self.content_available
    end
    
    if self.custom_data
      n.custom_data = JSON.parse(custom_data)
    end
    
    n
  end
  
  #
  # Build a new payload from the data expected from an API call
  #
  def self.build_from_payload(auth_key, payload)
    n = self.new
    n.auth_key = auth_key
    if payload[:device].is_a?(String)
      n.device = n.auth_key.touch_device(payload[:device])
    end
    
    if payload[:notification].is_a?(Hash)
      payload = payload[:notification]
      
      if payload[:alert].is_a?(String)
        n.alert_body = payload[:alert]
      elsif payload[:alert].is_a?(Hash)
        n.alert_body = payload[:alert][:body]
        n.action_loc_key = payload[:alert][:action_loc_key]
        n.loc_key = payload[:alert][:loc_key]
        if n.loc_args.is_a?(Array)
          n.loc_args = payload[:alert][:loc_args].to_json
        end
        n.launch_image = payload[:alert][:launch_image]
      end
    
      if payload[:badge].is_a?(Integer)
        n.badge = payload[:badge]
      end
    
      if payload[:sound].is_a?(String)
        n.sound = payload[:sound]
      end
    
      unless payload[:content_available].nil?
        n.content_available = !!payload[:content_available]
      end
    
      if payload[:custom_data].is_a?(Hash)
        n.custom_data = payload[:custom_data].to_json
      end
    end
    
    n
  end
  
end
