class CreateCartLogs < ActiveRecord::Migration
  def change
    create_table :cart_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :provider, index: true, foreign_key: true
      t.string :pin
      t.string :serial
      t.integer :price
      t.integer :coin
      t.integer :status

      t.timestamps null: false
    end
  end
end
