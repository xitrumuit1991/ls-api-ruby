class CreateTopUserSendGifts < ActiveRecord::Migration
  def change
    create_table :top_user_send_gifts do |t|
      t.references :broadcaster, index: true, foreign_key: true
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
