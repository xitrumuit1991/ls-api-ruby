class AddIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :username, unique: true
    add_index :users, :phone, unique: true
  end
end
