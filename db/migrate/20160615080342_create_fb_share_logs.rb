class CreateFbShareLogs < ActiveRecord::Migration
  def change
    create_table :fb_share_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.string :post_id
      t.string :coin

      t.timestamps null: false
    end
  end
end
