class AddDeviceIdToDeviceTokens < ActiveRecord::Migration
  def change
  	add_column :device_tokens, :device_id, :string, after: :user_id
  end
end
