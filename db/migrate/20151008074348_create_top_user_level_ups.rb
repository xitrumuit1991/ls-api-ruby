class CreateTopUserLevelUps < ActiveRecord::Migration
  def change
    create_table :top_user_level_ups do |t|
      t.references :broadcaster, index: true, foreign_key: true
      t.integer :times

      t.timestamps null: false
    end
  end
end
