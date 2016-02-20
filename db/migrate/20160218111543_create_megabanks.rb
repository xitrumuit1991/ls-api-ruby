class CreateMegabanks < ActiveRecord::Migration
  def change
    create_table :megabanks do |t|
      t.integer :price
      t.integer :coin

      t.timestamps null: false
    end
  end
end
