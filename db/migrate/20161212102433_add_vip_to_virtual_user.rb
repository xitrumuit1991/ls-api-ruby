class AddVipToVirtualUser < ActiveRecord::Migration
  def change
  	add_column :virtual_users, :vip, :integer, :default => 0, after: :fb_id
  end
end
