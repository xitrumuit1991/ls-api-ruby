class AddTransCodeToMbuyTransaction < ActiveRecord::Migration
  def change
  	add_column :mbuy_transactions, :trans_code, :string, after: :trans_id
  end
end
