class AddRoomIdToFbShareLog < ActiveRecord::Migration
  def change
    add_reference :fb_share_logs, :room, index: true, foreign_key: true, after: :user_id
  end
end
