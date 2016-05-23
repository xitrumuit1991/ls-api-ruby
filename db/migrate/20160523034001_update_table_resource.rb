class UpdateTableResource < ActiveRecord::Migration
  def change
  	rename_column :resources, :controller, :class_name
  	rename_column :resources, :action, :action_name
  end
end
