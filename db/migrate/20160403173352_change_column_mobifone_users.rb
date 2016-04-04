class ChangeColumnMobifoneUsers < ActiveRecord::Migration
  def change
  	rename_column :mobifone_users, :exprity_date, :expiry_date
  end
end
