class AddFieldsToCoin < ActiveRecord::Migration
  def change
  	change_column_default :coins, :price, 0
  	change_column_default :coins, :quantity, 0
  	add_column :coins, :price_usd, :float, default: 0, after: :price
  	add_column :coins, :bonus_percent, :float, default: 0, after: :quantity
  	add_column :coins, :bonus_coins, :integer, default: 0, after: :quantity
  end
end
