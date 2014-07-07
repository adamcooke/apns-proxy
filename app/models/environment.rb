# == Schema Information
#
# Table name: environments
#
#  id               :integer          not null, primary key
#  application_id   :integer
#  name             :string(255)
#  certificate      :text
#  created_at       :datetime
#  updated_at       :datetime
#  apns_environment :string(255)
#
# Indexes
#
#  index_environments_on_application_id  (application_id)
#

class Environment < ActiveRecord::Base
  
  APNS_ENVIRONMENTS = {
    :development => {
      :gateway  => "apn://gateway.sandbox.push.apple.com:2195",
      :feedback => "apn://feedback.sandbox.push.apple.com:2196"
    },
    :production => {
      :gateway  => "apn://gateway.push.apple.com:2195",
      :feedback => "apn://feedback.push.apple.com:2196"
    }
  }
  
  belongs_to :application
  has_many :auth_keys, :dependent => :destroy
  
  validates :name, :presence => true, :length => {:maximum => 50}
  validates :apns_environment, :inclusion => {:in => APNS_ENVIRONMENTS.keys.map(&:to_s) }
  validates :certificate, :presence => true
  
  scope :asc, -> { order(:name) }
  
  def create_connection(type = :gateway)
    Houston::Connection.new(self.apns_environment_details[type], self.certificate, nil)
  end
  
  def apns_environment_details
    APNS_ENVIRONMENTS[self.apns_environment.to_sym]
  end
  
  #
  # Return an array of device IDs which should be unsubscribed because they have
  # received repeated failed messages for this application.
  #
  def devices_to_unsubscribe
    devices = []
    connection = self.create_connection(:feedback)
    connection.open
    while line = connection.read(38)
      feedback = line.unpack('N1n1H140')
      timestamp = Time.at(feedback[0])
      token = feedback[2].scan(/.{0,8}/).join(' ').strip
      if token && timestamp
        devices << {:token => token, :timestamp => timestamp}
      end
    end
    connection.close
    devices
  rescue OpenSSL::PKey::RSAError
    []
  end
  
  #
  # Unsubscribe all devices which need to be un-subscribed
  #
  def self.unsubscribe_devices
    self.all.each do |environment|
      puts "Checking #{environment.name.yellow} for #{environment.application.name.yellow}"
      devices = environment.devices_to_unsubscribe
      puts "Found #{devices.size} device(s) to unsubscribe..."
      devices.each do |details|
        if device = Device.where(:auth_key_id => environment.auth_keys.pluck(:id), :token => details[:token]).first
          if device.last_registered_at > details[:timestamp]
            puts "----> No need to un-subscribe #{device.id} because it has registered since APNS unsubscribed it."
          else
            device.unsubscribed_at = Time.now
            device.save!
            puts "----> Unsubscribed device ##{device.id}".green
          end
        else
          puts "----> Could not unsubscribe '#{details[:token]}' as it was not known to us."
        end
      end
    end
  end
  
end
