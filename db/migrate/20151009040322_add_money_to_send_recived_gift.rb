class AddMoneyToSendRecivedGift < ActiveRecord::Migration
  def change
    add_column :top_bct_received_gifts, :money, :float, after: :quantity
    add_column :weekly_top_bct_received_gifts, :money, :float, after: :quantity
    add_column :monthly_top_bct_received_gifts, :money, :float, after: :quantity

    add_column :top_user_send_gifts, :money, :float, after: :quantity
    add_column :weekly_top_user_send_gifts, :money, :float, after: :quantity
    add_column :monthly_top_user_send_gifts, :money, :float, after: :quantity
  end
end
