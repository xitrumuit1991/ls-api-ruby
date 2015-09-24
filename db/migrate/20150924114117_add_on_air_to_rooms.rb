class AddOnAirToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :on_air, :boolean, default: false, after: :background
  end
end
