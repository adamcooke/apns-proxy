# == Schema Information
#
# Table name: devices
#
#  id              :integer          not null, primary key
#  auth_key_id     :integer
#  token           :string(255)
#  usage           :integer          default(0)
#  last_used_at    :datetime
#  unsubscribed_at :datetime
#  created_at      :datetime
#

class Device < ActiveRecord::Base
  
  belongs_to :auth_key
  has_many :notifications, :dependent => :destroy
  
  validates :auth_key_id, :presence => true
  validates :token, :presence => true
  
  def unsubscribed?
    !!unsubscribed_at
  end
  
  def self.touch_device(auth_key, token)
    device = self.where(:auth_key_id => auth_key.id, :token => token).first
    if device.nil?
      device = self.new
      device.auth_key = auth_key
      device.token = token
    end
    device.usage += 1
    device.last_used_at = Time.now
    device.save!
    device
  end
  
end
