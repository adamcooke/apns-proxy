class AddIndexes < ActiveRecord::Migration
  def change
    add_index :auth_keys, :application_id
    add_index :auth_keys, :environment_id
    add_index :devices, :auth_key_id
    add_index :environments, :application_id
    add_index :notifications, :auth_key_id
    add_index :notifications, :device_id
    add_index :notifications, :pushed_at
  end
end