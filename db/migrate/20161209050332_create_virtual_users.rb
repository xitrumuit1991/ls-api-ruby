class CreateVirtualUsers < ActiveRecord::Migration
  def change
    create_table :virtual_users do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :avatar
      t.string :fb_id

      t.timestamps null: false
    end
  end
end
