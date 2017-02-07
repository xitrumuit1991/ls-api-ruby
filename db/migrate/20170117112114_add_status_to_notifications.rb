class AddStatusToNotifications < ActiveRecord::Migration
  def change
  	add_column :notifications, :status, :boolean, default: false, after: :description
  end
end
