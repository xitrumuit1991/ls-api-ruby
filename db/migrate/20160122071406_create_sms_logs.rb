class CreateSmsLogs < ActiveRecord::Migration
  def change
    create_table :sms_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.string :moid
      t.string :phone
      t.string :shortcode
      t.string :keyword
      t.text :content
      t.string :trans_date
      t.string :checksun
      t.integer :amount

      t.timestamps null: false
    end
  end
end
