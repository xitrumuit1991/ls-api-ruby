class DropTableMobifoneUsers < ActiveRecord::Migration
  def change
  	drop_table :mobifone_users
  end
end
