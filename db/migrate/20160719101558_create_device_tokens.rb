class CreateDeviceTokens < ActiveRecord::Migration
  def change
    create_table :device_tokens do |t|
      t.references :user, index: true, foreign_key: true
      t.string :device_token, limit: 255
      t.string :device_type, limit: 20

      t.timestamps null: false
    end
  end
end
