class AddGenderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string, limit: 6
  end
end
