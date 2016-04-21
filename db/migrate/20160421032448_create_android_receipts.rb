class CreateAndroidReceipts < ActiveRecord::Migration
  def change
    create_table :android_receipts do |t|
      t.references :user, index: true, foreign_key: true
      t.string :orderId
      t.string :packageName
      t.string :productId
      t.date :purchaseTime
      t.integer :purchaseState
      t.string :purchaseToken
      t.boolean :status, default: false

      t.timestamps null: false
    end
  end
end
