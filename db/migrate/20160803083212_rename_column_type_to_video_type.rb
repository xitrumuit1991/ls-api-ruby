class RenameColumnTypeToVideoType < ActiveRecord::Migration
  def change
  	rename_column :bct_videos, :type, :video_type
  end
end
