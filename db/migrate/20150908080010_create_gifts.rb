class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.string :name, 	limit: 45
      t.string :image, 	limit: 45
      t.integer :price
      t.float :discount

      t.timestamps null: false
    end
  end
end
