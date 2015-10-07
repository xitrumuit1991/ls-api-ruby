class CreateGiftLogs < ActiveRecord::Migration
  def change
    create_table :gift_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :room, index: true, foreign_key: true
      t.references :gift, index: true, foreign_key: true
      t.integer :quantity
      t.float :cost

      t.timestamps null: false
    end
  end
end
