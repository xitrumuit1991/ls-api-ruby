class CreateBctImages < ActiveRecord::Migration
  def change
    create_table :bct_images do |t|
      t.references :broadcaster, index: true, foreign_key: true
      t.string :image

      t.timestamps null: false
    end
  end
end
