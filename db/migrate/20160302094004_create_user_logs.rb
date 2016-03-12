class CreateUserLogs < ActiveRecord::Migration
  def change
    create_table :user_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :room, index: true, foreign_key: true
      t.float :money

      t.timestamps null: false
    end
  end
end
