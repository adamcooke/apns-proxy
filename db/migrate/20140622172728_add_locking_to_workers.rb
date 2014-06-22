class AddLockingToWorkers < ActiveRecord::Migration
  def change
    add_column :notifications, :locked, :boolean, :default => false
  end
end