class AddDeletedToIdolUser < ActiveRecord::Migration
  def change
  	add_column :users, :deleted, :boolean, default: 0, after: :user_level_id
  	add_column :broadcasters, :deleted, :boolean, default: 0, after: :recived_heart
  end
end
