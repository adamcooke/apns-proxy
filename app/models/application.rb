# == Schema Information
#
# Table name: applications
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  api_key    :string(255)
#

class Application < ApplicationRecord

  has_many :environments, :dependent => :destroy
  has_many :auth_keys, :dependent => :destroy
  has_many :notifications, :through => :auth_keys

  validates :name, :presence => true, :length => {:maximum => 100}

  scope :asc, -> { order(:name) }

  before_create do
    if self.api_key.blank?
      self.api_key = SecureRandom.uuid
    end
  end

  after_create do
    release = self.environments.create!(:name => 'Release', :apns_environment => 'production', :topic => "com.example.app", :certificate => 'Insert your certificate here...')
    debug = self.environments.create!(:name => 'Debug', :apns_environment => 'development', :topic => "com.example.app", :certificate => 'Insert your certificate here...')
    self.auth_keys.create!(:name => 'Auth Key for Release', :environment => release)
    self.auth_keys.create!(:name => 'Auth Key for Debug', :environment => debug)
  end

end
