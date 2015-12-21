class AddAvatarCropToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_crop, :string, after: :avatar
  end
end
