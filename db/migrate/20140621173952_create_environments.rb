class CreateEnvironments < ActiveRecord::Migration
  def change
    create_table :environments do |t|
      t.integer :application_id
      t.string :name
      t.text :certificate
      t.timestamps
    end
  end
end
