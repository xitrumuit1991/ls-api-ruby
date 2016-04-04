class UpdateColumnMobifoneUsers < ActiveRecord::Migration
  def change
  	change_column_null :mobifone_users, :sub_id, false
    add_index :mobifone_users, :sub_id, unique: true
    remove_column :mobifone_users, :pkg_charged
  end
end
