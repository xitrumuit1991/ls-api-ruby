class CreateScreenTextLogs < ActiveRecord::Migration
  def change
    create_table :screen_text_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :room, index: true, foreign_key: true
      t.text :content
      t.float :cost

      t.timestamps null: false
    end
  end
end
