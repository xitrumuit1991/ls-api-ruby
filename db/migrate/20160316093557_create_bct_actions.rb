class CreateBctActions < ActiveRecord::Migration
  def change
    create_table :bct_actions do |t|
      t.references :room, index: true, foreign_key: true
      t.references :room_action, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
