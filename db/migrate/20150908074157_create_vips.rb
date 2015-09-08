class CreateVips < ActiveRecord::Migration
  def change
    create_table :vips do |t|
      t.string :name,               limit: 45
      t.string :code,               limit: 45
      t.string :image,              limit: 512
      t.integer :weight
      t.integer :no_char
      t.integer :screen_text_time
      t.string :screen_text_effect, limit: 45
      t.integer :kick_level
      t.integer :clock_kick
      t.boolean :clock_ads
      t.float :exp_bonus

      t.timestamps null: false
    end
  end
end
