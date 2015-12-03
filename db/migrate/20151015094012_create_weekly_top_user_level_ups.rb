class CreateWeeklyTopUserLevelUps < ActiveRecord::Migration
  def change
    create_table :weekly_top_user_level_ups do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :times

      t.timestamps null: false
    end
  end
end
