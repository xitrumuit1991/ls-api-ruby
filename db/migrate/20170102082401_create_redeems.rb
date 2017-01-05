class CreateRedeems < ActiveRecord::Migration
  def change
    create_table :redeems do |t|
      t.string :code, limit: 10
      t.string :name, limit: 255
      t.integer :coin
      t.boolean :status, default: true
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :deleted, default: false

      t.timestamps null: false
    end
  end
end
