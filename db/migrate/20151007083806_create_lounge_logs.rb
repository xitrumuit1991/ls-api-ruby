class CreateLoungeLogs < ActiveRecord::Migration
  def change
    create_table :lounge_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :room, index: true, foreign_key: true
      t.integer :lounge
      t.float :cost

      t.timestamps null: false
    end
  end
end
