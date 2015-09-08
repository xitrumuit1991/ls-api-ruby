class CreateBroadcasters < ActiveRecord::Migration
  def change
    create_table :broadcasters do |t|
      t.references :user, index: true, foreign_key: true
      t.references :bct_type, index: true, foreign_key: true
      t.references :broadcaster_level, index: true, foreign_key: true
      t.string :fullname
      t.string :fb_link,          limit: 2048
      t.string :twitter_link,     limit: 2048
      t.string :instagram_link,   limit: 2048
      t.text :description
      t.integer :broadcaster_exp
      t.integer :recived_heart

      t.timestamps null: false
    end
  end
end
