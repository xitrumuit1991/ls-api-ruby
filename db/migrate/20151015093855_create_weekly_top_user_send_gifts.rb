class CreateWeeklyTopUserSendGifts < ActiveRecord::Migration
  def change
    create_table :weekly_top_user_send_gifts do |t|
      t.references :user, index: true, foreign_key: true
      t.references :room, index: true, foreign_key: true
      t.integer :quantity
      t.float :money

      t.timestamps null: false
    end
  end
end
