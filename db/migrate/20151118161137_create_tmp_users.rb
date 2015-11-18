class CreateTmpUsers < ActiveRecord::Migration
  def change
    create_table :tmp_users do |t|
      t.string :name
      t.string :email
      t.string :exp
      t.text :token

      t.timestamps null: false
    end
  end
end
