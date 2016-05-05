class AddImageToCoin < ActiveRecord::Migration
  def change
  	add_column :coins, :image, :string, after: :bonus_percent
  end
end
