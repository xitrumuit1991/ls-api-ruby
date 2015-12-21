class AddCoverCropToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cover_crop, :string, after: :cover
  end
end
