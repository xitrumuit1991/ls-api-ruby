class CreateSmsMobiles < ActiveRecord::Migration
  def change
    create_table :sms_mobiles do |t|
      t.integer :price
      t.integer :coin

      t.timestamps null: false
    end
  end
end
