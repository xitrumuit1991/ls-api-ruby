class CreateBctGifts < ActiveRecord::Migration
  def change
    create_table :bct_gifts do |t|
      t.references :room, index: true, foreign_key: true
      t.references :gift, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
