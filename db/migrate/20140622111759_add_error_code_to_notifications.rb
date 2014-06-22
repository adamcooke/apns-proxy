class AddErrorCodeToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :error_code, :integer
  end
end