class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :bankID
      t.string :name
      t.boolean :status

      t.timestamps null: false
    end
  end
end
