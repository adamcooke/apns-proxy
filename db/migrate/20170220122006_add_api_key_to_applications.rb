class AddApiKeyToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :api_key, :string
    Application.where(:api_key => nil).each do |a|
      a.update_column(:api_key, SecureRandom.uuid)
    end
  end
end
