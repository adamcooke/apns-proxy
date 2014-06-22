# == Schema Information
#
# Table name: environments
#
#  id             :integer          not null, primary key
#  application_id :integer
#  name           :string(255)
#  certificate    :text
#  created_at     :datetime
#  updated_at     :datetime
#

class Environment < ActiveRecord::Base
  
  belongs_to :application
  has_many :auth_keys, :dependent => :destroy
  
  validates :name, :presence => true, :length => {:maximum => 50}
  validates :certificate, :presence => true
  
  scope :asc, -> { order(:name) }
  
  def create_connection
    Houston::Connection.new(Houston::APPLE_DEVELOPMENT_GATEWAY_URI, self.certificate, nil)
  end
  
end
