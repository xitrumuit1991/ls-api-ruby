class CreateMobifoneUsers < ActiveRecord::Migration
  def change
    create_table :mobifone_users, {:id => false} do |t|
      t.integer :id
      t.references :user, index: true, foreign_key: true
      t.string :sub_id
      t.string :pkg_code
      t.string :register_channel
      t.datetime :pkg_actived
      t.datetime :pkg_charged
      t.boolean :status

      t.timestamps null: false
    end
    execute "ALTER TABLE mobifone_users ADD PRIMARY KEY (id);"
  end
end
