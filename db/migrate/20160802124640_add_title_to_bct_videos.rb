class AddTitleToBctVideos < ActiveRecord::Migration
  def change
    add_column :bct_videos, :title, :string, limit: 255, after: :broadcaster_id
  end
end
