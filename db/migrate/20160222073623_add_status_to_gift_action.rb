class AddStatusToGiftAction < ActiveRecord::Migration
  def change
    add_column :gifts, :status, :boolean, default: false, after: :discount
    add_column :room_actions, :status, :boolean, default: false, after: :discount
  end
end
