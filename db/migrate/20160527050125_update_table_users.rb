class UpdateTableUsers < ActiveRecord::Migration
  def change
  	change_column :users, :is_broadcaster, :boolean, default: 0
  	change_column :users, :is_banned, :boolean, default: 0
  end
end
