class SetDefaultValForExpMoneyHeart < ActiveRecord::Migration
  def change
  	change_column :broadcasters, :broadcaster_exp, :integer, default: 0
  	change_column :broadcasters, :recived_heart, :integer, default: 0

  	change_column :users, :money, :integer, default: 0
  	change_column :users, :user_exp, :integer, default: 0
  	change_column :users, :no_heart, :integer, default: 0
  end
end
