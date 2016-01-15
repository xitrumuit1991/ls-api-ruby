class AddForgotCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :forgot_code, :string
  end
end
