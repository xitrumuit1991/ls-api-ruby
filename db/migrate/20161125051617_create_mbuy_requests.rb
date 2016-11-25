class CreateMbuyRequests < ActiveRecord::Migration
  def change
    create_table :mbuy_requests do |t|
      t.string :command
      t.string :cp_code
      t.string :content_code
      t.string :total_amount
      t.string :account
      t.string :isdn
      t.string :result

      t.timestamps null: false
    end
  end
end
