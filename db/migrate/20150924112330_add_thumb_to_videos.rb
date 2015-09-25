class AddThumbToVideos < ActiveRecord::Migration
  def change
    add_column :bct_videos, :thumb, :string, after: :video
  end
end
