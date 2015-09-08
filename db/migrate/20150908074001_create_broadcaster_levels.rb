class CreateBroadcasterLevels < ActiveRecord::Migration
  def change
    create_table :broadcaster_levels do |t|
      t.integer :level
      t.integer :min_heart,      :limit => 8
      t.integer :grade

      t.timestamps null: false
    end
  end
end
