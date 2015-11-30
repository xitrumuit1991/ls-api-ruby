class DeleteBackgroundAddReferencesRoomBGandBroadcasterBg < ActiveRecord::Migration
  def change
  	remove_column :rooms, :background
  	add_reference :rooms, :room_background, index: true, foreign_key: true, after: :room_type_id
  	add_reference :rooms, :broadcaster_background, index: true, foreign_key: true, after: :room_type_id
  end
end
