class CreateRoomBackgrounds < ActiveRecord::Migration
  def change
    create_table :room_backgrounds do |t|
      t.string :image

      t.timestamps null: false
    end
  end
end
