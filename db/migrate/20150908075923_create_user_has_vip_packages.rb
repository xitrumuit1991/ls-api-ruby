class CreateUserHasVipPackages < ActiveRecord::Migration
  def change
    create_table :user_has_vip_packages do |t|
      t.references :user, index: true, foreign_key: true
      t.references :vip_package, index: true, foreign_key: true
      t.boolean :actived
      t.datetime :active_date
      t.datetime :expiry_date

      t.timestamps null: false
    end
  end
end
