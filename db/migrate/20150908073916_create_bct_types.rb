class CreateBctTypes < ActiveRecord::Migration
  def change
    create_table :bct_types do |t|
      t.string :title
      t.string :slug
      t.text :description

      t.timestamps null: false
    end
  end
end
