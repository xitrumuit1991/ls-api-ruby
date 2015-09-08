class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.references :broadcaster, index: true, foreign_key: true
      t.references :room_type, index: true, foreign_key: true
      t.string :title
      t.string :slug
      t.string :thumb,         limit: 512
      t.string :background,    limit: 512
      t.boolean :is_privated

      t.timestamps null: false
    end
  end
end
