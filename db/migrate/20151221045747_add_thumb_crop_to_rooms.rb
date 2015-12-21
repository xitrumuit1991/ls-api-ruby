class AddThumbCropToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :thumb_crop, :string, after: :thumb
  end
end
