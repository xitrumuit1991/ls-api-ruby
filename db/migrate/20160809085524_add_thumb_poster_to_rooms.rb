class AddThumbPosterToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :thumb_poster, :string, limit: 255, after: :thumb_crop
  end
end
