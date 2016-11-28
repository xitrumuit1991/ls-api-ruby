class CreateMbuyTransactions < ActiveRecord::Migration
  def change
    create_table :mbuy_transactions do |t|
      t.string :trans_id
      t.string :isdn
      t.string :total_amount
      t.string :checksum
      t.references :user, index: true, foreign_key: true
      t.string :response
      t.integer :status

      t.timestamps null: false
    end
  end
end
