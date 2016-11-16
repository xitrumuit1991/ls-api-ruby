class CreateBctTimeLogs < ActiveRecord::Migration
  def change
    create_table :bct_time_logs do |t|
      t.references :room, index: true, foreign_key: true
      t.datetime :last_login
      t.datetime :start_room
      t.datetime :end_room
      t.boolean :status, default: true
      t.boolean :flag, default: false

      t.timestamps null: false
    end
  end
end
