class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :auth_key_id
      t.integer :device_id
      t.datetime :pushed_at
      t.datetime :created_at
      t.string :alert_body
      t.string :action_loc_key
      t.string :loc_key
      t.text :loc_args
      t.string :launch_image
      t.integer :badge
      t.string :sound
      t.boolean :content_available
      t.text :custom_data
      
    end
  end
end
