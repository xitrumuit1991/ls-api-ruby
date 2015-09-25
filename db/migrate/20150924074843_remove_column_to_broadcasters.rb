class RemoveColumnToBroadcasters < ActiveRecord::Migration
  def change
    remove_column :broadcasters, :fb_link
    remove_column :broadcasters, :twitter_link
    remove_column :broadcasters, :instagram_link
  end
end
