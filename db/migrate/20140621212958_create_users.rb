class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, :password_digest, :name, :email_address
      t.timestamps
    end
  end
end
