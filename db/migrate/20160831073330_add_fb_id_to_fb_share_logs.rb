class AddFbIdToFbShareLogs < ActiveRecord::Migration
  def change
    add_column :fb_share_logs, :fb_id, :string, limit: 100, after: :user_id
  end
end
