class CreateIosReceipts < ActiveRecord::Migration
  def change
    create_table :ios_receipts do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :quantity
      t.string :product_id
      t.string :transaction_id
      t.string :original_transaction_id
      t.string :purchase_date
      t.string :purchase_date_ms
      t.string :purchase_date_pst
      t.string :original_purchase_date
      t.string :original_purchase_date_ms
      t.string :original_purchase_date_pst
      t.string :is_trial_period

      t.timestamps null: false
    end
  end
end
