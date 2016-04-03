class CreateMobifoneUserVipLogs < ActiveRecord::Migration
  def change
    create_table :mobifone_user_vip_logs do |t|
      t.references :mobifone_user, index: true, foreign_key: true
      t.references :user_has_vip_package, index: true, foreign_key: true
      t.string :pkg_code

      t.timestamps null: false
    end
  end
end
