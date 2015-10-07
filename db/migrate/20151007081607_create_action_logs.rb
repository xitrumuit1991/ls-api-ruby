class CreateActionLogs < ActiveRecord::Migration
  def change
    create_table :action_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :room, index: true, foreign_key: true
      t.references :room_action, index: true, foreign_key: true
      t.float :cost

      t.timestamps null: false
    end
  end
end
