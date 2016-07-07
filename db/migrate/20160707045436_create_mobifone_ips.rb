class CreateMobifoneIps < ActiveRecord::Migration
  def change
    create_table :mobifone_ips, id: false do |t|
      t.string :ip

      t.timestamps null: false
    end
    execute "ALTER TABLE mobifone_ips ADD PRIMARY KEY (ip);"
  end
end
