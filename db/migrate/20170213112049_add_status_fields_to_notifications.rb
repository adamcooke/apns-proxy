class AddStatusFieldsToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :status_code, :string
    add_column :notifications, :status_reason, :string
  end
end
