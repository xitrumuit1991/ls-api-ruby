class CreateMobifoneUsers < ActiveRecord::Migration
  def change
    create_table :mobifone_users do |t|
      t.references :user, index: true, foreign_key: true
      t.string :sub_id
      t.string :pkg_code
      t.string :register_channel
      t.datetime :active_date
      t.datetime :exprity_date
      t.datetime :pkg_charged
      t.boolean :status

      t.timestamps null: false
    end
  end
end
