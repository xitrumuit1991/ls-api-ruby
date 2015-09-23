class SetDefaultValueToUser < ActiveRecord::Migration
  def change
    change_column :users, :actived, :boolean, default: false
  end
end
