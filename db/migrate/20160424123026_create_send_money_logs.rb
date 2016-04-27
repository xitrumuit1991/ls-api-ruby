class CreateSendMoneyLogs < ActiveRecord::Migration
  def change
    create_table :send_money_logs do |t|
      t.string :from
      t.references :user, index: true, foreign_key: true
      t.integer :money
      t.string :note

      t.timestamps null: false
    end
  end
end
