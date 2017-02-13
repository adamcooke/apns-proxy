class AddAppIdentifierToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :topic, :string
  end
end
