class AddExpirationToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :expiration, :datetime
  end
end
