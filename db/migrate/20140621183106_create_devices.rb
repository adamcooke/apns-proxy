class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :auth_key_id
      t.string :token
      t.integer :usage, :default => 0
      t.datetime :last_used_at
      t.datetime :unsubscribed_at
      t.datetime :created_at
    end
  end
end
