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

class User < ApplicationRecord

  include Authie::User
  include LogLogins::User

  has_secure_password

  validates :username, :presence => true, :uniqueness => true
  validates :name, :presence => true
  validates :email_address, :presence => true

  scope :asc, -> { order(:name) }

  def self.authenticate(username, password, ip)
    user = self.where("username = ? OR email_address = ?", username, username).first
    if user.nil?
      LogLogins.fail(username, nil, ip)
      return nil
    end

    unless user.authenticate(password)
      LogLogins.fail(username, user, ip)
      return nil
    end

    LogLogins.success(username, user, ip)
    return user
  end

end
