class AddFieldToMbuyRequest < ActiveRecord::Migration
  def change
  	add_column :mbuy_requests, :total_final, :string, after: :total_amount
  end
end
