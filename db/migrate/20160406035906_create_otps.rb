class CreateOtps < ActiveRecord::Migration
  def change
    create_table :otps do |t|
      t.references :user, index: true, foreign_key: true
      t.string :code
      t.string :service
      t.boolean :used, default: false

      t.timestamps null: false
    end
  end
end
