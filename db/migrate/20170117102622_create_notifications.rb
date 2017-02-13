class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :room, index: true, foreign_key: true
      t.references :admin, index: true, foreign_key: true
      t.string :title, limit: 255
      t.string :description, limit: 255

      t.timestamps null: false
    end
  end
end
