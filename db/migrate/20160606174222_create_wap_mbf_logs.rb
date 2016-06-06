class CreateWapMbfLogs < ActiveRecord::Migration
  def change
    create_table :wap_mbf_logs do |t|
      t.string :msisdn
      t.integer :sp_id
      t.string :trans_id
      t.string :pkg
      t.integer :price
      t.text :information
      t.boolean :status

      t.timestamps null: false
    end
  end
end
