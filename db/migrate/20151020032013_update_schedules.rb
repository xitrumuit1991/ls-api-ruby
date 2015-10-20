class UpdateSchedules < ActiveRecord::Migration
  def change
    remove_column :schedules, :date
    remove_column :schedules, :start
    remove_column :schedules, :end

    add_column :schedules, :end, :datetime, after: :id
    add_column :schedules, :start, :datetime, after: :id
  end
end
