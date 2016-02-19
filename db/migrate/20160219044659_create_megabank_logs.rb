class CreateMegabankLogs < ActiveRecord::Migration
  def change
    create_table :megabank_logs do |t|
      t.references :bank, index: true, foreign_key: true
      t.references :megabank, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.text :descriptionvn
      t.text :descriptionen
      t.string :responsecode
      t.string :status

      t.timestamps null: false
    end
  end
end
