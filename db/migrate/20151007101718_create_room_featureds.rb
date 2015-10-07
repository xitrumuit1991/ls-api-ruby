class CreateRoomFeatureds < ActiveRecord::Migration
  def change
    create_table :room_featureds do |t|
      t.references :broadcaster, index: true, foreign_key: true
      t.integer :weight

      t.timestamps null: false
    end
  end
end
