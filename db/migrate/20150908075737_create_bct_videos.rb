class CreateBctVideos < ActiveRecord::Migration
  def change
    create_table :bct_videos do |t|
      t.references :broadcaster, index: true, foreign_key: true
      t.string :video

      t.timestamps null: false
    end
  end
end
