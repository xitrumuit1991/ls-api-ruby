class CreateRoomTypes < ActiveRecord::Migration
  def change
    create_table :room_types do |t|
      t.string :title
      t.string :slug, 			limit: 45
      t.text :description

      t.timestamps null: false
    end
  end
end
