class CreateHeartLogs < ActiveRecord::Migration
  def change
    create_table :heart_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :room, index: true, foreign_key: true
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
