class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :name,       limit: 45
      t.string :image,      limit: 512
      t.integer :price,     :limit => 8
      t.integer :max_vote
      t.float :discount

      t.timestamps null: false
    end
  end
end
