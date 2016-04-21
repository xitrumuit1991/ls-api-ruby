class CreateCoins < ActiveRecord::Migration
  def change
    create_table :coins do |t|
      t.string :name
      t.string :code
      t.integer :price
      t.integer :quantity
      t.string :app

      t.timestamps null: false
    end
  end
end
