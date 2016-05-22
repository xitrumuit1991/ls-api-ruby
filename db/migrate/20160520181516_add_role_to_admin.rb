class AddRoleToAdmin < ActiveRecord::Migration
  def change
    add_reference :admins, :role, index: true, foreign_key: true, after: :id
  end
end
