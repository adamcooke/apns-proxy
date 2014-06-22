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
  
  def create_connection
    Houston::Connection.new(self.apns_environment_details[:gateway], self.certificate, nil)
  end
  
  def apns_environment_details
    APNS_ENVIRONMENTS[self.apns_environment.to_sym]
  end
  
end
