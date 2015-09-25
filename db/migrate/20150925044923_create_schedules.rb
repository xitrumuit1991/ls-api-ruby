class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.references :room, index: true, foreign_key: true
      t.date :date
      t.string :start
      t.string :end

      t.timestamps null: false
    end
  end
end
