# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  username        :string(255)
#  password_digest :string(255)
#  name            :string(255)
#  email_address   :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class User < ActiveRecord::Base
  
  has_secure_password
  
  validates :username, :presence => true
  validates :name, :presence => true
  validates :email_address, :presence => true
  
  scope :asc, -> { order(:name) }
  
  def self.authenticate(username, password)
    user = self.where("username = ? OR email_address = ?", username, username).first
    return nil unless user
    return nil unless user.authenticate(password)
    return user
  end
  
end
