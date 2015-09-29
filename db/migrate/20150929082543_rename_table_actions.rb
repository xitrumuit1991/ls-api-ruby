class RenameTableActions < ActiveRecord::Migration
  def change
    rename_table :actions, :room_actions
  end
end
