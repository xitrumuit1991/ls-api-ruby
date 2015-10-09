class CreateWeeklyTopBctReceivedGifts < ActiveRecord::Migration
  def change
    create_table :weekly_top_bct_received_gifts do |t|
      t.references :broadcaster, index: true, foreign_key: true
      t.integer :quantity

      t.timestamps null: false
    end
  end
end