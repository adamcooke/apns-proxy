class AddAppleEnvironmentToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :apns_environment, :string
  end
end