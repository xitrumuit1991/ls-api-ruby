class CreateUserLevels < ActiveRecord::Migration
  def change
    create_table :user_levels do |t|
      t.integer :level
      t.integer :min_exp,      :limit => 8
      t.integer :heart_per_day
      t.integer :grade

      t.timestamps null: false
    end
  end
end
