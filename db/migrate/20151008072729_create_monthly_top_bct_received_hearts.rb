class CreateMonthlyTopBctReceivedHearts < ActiveRecord::Migration
  def change
    create_table :monthly_top_bct_received_hearts do |t|
      t.references :broadcaster, index: true, foreign_key: true
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
