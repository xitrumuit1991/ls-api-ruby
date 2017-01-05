class CreateRedeemLogs < ActiveRecord::Migration
  def change
    create_table :redeem_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :redeem, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
