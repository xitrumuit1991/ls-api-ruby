class CreateSlides < ActiveRecord::Migration
  def change
    create_table :slides do |t|
      t.string :title
      t.string :description
      t.string :sub_description
      t.datetime :start_time
      t.integer :weight
      t.string :link
      t.string :banner
      t.string :thumb

      t.timestamps null: false
    end
  end
end
