class AddDeviceIdToFbShareLogs < ActiveRecord::Migration
  def change
  	add_column :fb_share_logs, :device_id, :string, limit: 255, after: :post_id
  end
end
