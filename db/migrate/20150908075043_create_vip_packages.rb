class CreateVipPackages < ActiveRecord::Migration
  def change
    create_table :vip_packages do |t|
      t.references :vip, index: true, foreign_key: true
      t.string :name,         limit: 45
      t.string :code,         limit: 45
      t.string :no_day,       limit: 45
      t.integer :price,      :limit => 8
      t.float :discount

      t.timestamps null: false
    end
  end
end
