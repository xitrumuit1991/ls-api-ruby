class AddBctToUserSendGift < ActiveRecord::Migration
  def change
    add_reference :top_user_send_gifts, :broadcaster, index: true, foreign_key: true
    add_reference :weekly_top_user_send_gifts, :broadcaster, index: true, foreign_key: true
    add_reference :monthly_top_user_send_gifts, :broadcaster, index: true, foreign_key: true
  end
end
