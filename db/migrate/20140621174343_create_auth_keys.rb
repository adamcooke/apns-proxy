class CreateAuthKeys < ActiveRecord::Migration
  def change
    create_table :auth_keys do |t|
      t.integer :application_id
      t.string :name, :key
      t.integer :environment_id
      t.timestamps
    end
  end
end
