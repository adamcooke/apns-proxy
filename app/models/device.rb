# == Schema Information
#
# Table name: devices
#
#  id                        :integer          not null, primary key
#  auth_key_id               :integer
#  token                     :string(255)
#  usage                     :integer          default(0)
#  last_sent_notification_at :datetime
#  unsubscribed_at           :datetime
#  created_at                :datetime
#  last_registered_at        :datetime
#  label                     :string(255)
#
# Indexes
#
#  index_devices_on_auth_key_id  (auth_key_id)
#

class Device < ApplicationRecord

  belongs_to :auth_key
  has_many :notifications, :dependent => :destroy

  validates :auth_key_id, :presence => true
  validates :token, :presence => true

  def unsubscribed?
    !!unsubscribed_at
  end

  def unsubscribe!
    self.unsubscribed_at = Time.now
    self.save!
  end

  def self.touch_device(auth_key, token, options = {})
    device = self.where(:auth_key_id => auth_key.id, :token => token).first
    if device.nil?
      device = self.new
      device.auth_key = auth_key
      device.token = token
      device.last_registered_at = Time.now
    end
    device.label = options[:label] if options[:label].present?
    device.usage += 1
    device.last_sent_notification_at = Time.now
    device.save!
    device
  end

end
