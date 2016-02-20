class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.string :slug
      t.text :description

      t.timestamps null: false
    end
  end
end
