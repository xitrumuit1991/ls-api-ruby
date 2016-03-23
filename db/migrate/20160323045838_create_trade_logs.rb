class CreateTradeLogs < ActiveRecord::Migration
  def change
    create_table :trade_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :vip_package, index: true, foreign_key: true
      t.boolean :status

      t.timestamps null: false
    end
  end
end
