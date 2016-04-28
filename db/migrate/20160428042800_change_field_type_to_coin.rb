class ChangeFieldTypeToCoin < ActiveRecord::Migration
  def change
  	change_column :coins, :price, :float
  end
end
