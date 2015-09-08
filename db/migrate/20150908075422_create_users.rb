class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :username
      t.string :name
      t.date :birthday
      t.string :gender,           limit: 5
      t.string :address,          limit: 512
      t.string :phone,            limit: 45
      t.string :fb_id,            limit: 128
      t.string :gp_id,            limit: 128
      t.string :avatar,           limit: 512
      t.string :cover,            limit: 512
      t.integer :money
      t.integer :user_exp
      t.string :active_code,      limit: 10
      t.boolean :actived
      t.datetime :active_date
      t.boolean :is_broadcaster
      t.integer :no_heart
      t.boolean :is_banned
      t.references :user_level, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
