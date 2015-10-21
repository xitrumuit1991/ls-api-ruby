class CreatePosters < ActiveRecord::Migration
  def change
    create_table :posters do |t|
      t.string :title
      t.string :sub_title
      t.string :thumb
      t.string :link
      t.integer :weight

      t.timestamps null: false
    end
  end
end
