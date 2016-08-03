class AddTypeToBctVideos < ActiveRecord::Migration
  def change
    add_column :bct_videos, :type, :string, limit: 50, after: :title
  end
end
