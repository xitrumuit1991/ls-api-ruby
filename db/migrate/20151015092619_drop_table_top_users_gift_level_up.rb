class DropTableTopUsersGiftLevelUp < ActiveRecord::Migration
  def change
    drop_table :top_user_send_gifts
    drop_table :weekly_top_user_send_gifts
    drop_table :monthly_top_user_send_gifts

    drop_table :top_user_level_ups
    drop_table :weekly_top_user_level_ups
    drop_table :monthly_top_user_level_ups
  end
end
