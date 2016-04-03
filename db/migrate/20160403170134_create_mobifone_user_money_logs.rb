class CreateMobifoneUserMoneyLogs < ActiveRecord::Migration
  def change
    create_table :mobifone_user_money_logs do |t|
      t.references :mobifone_user, index: true, foreign_key: true
      t.string :money
      t.string :info

      t.timestamps null: false
    end
  end
end
