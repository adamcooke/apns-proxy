class AddPriorityToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :priority, :integer
  end
end
