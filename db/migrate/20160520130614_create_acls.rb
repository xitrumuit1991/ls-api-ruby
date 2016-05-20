class CreateAcls < ActiveRecord::Migration
  def change
    create_table :acls do |t|
      t.references :role, index: true, foreign_key: true
      t.references :resource, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
