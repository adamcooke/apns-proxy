class AddDeviceRegistrationTime < ActiveRecord::Migration
  def change
    rename_column :devices, :last_used_at, :last_sent_notification_at
    add_column :devices, :last_registered_at, :datetime
  end
end