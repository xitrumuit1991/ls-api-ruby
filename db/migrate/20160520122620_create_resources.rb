class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name
      t.text :description
      t.string :controller
      t.string :action
      t.string :can

      t.timestamps null: false
    end
  end
end
