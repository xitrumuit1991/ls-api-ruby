class CreateBanUsers < ActiveRecord::Migration
  def change
    create_table :ban_users do |t|
      t.references :user, index: true, foreign_key: true
      t.references :room, index: true, foreign_key: true
      t.integer :days
      t.string :note

      t.timestamps null: false
    end
  end
end
