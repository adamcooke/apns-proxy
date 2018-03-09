# This migration comes from authie_two_factor_engine (originally 20180308103500)
class CreateInitialTables < ActiveRecord::Migration[4.2]

  def change
    create_table :authie_2f_profiles do |t|
      t.string :user_type
      t.integer :user_id
      t.string :token, :token_iv
      t.integer :attempts, :default => 0
      t.datetime :last_attempt_at
      t.datetime :last_verified_at
      t.boolean :active, :default => false
      t.timestamps
      t.index :user_id
    end

    create_table :authie_2f_recovery_tokens do |t|
      t.string :user_type
      t.integer :user_id
      t.string :token
      t.datetime :used_at
      t.timestamps
      t.index :user_id
    end
  end

end
