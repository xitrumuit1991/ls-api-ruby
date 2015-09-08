class CreateUserFollowBcts < ActiveRecord::Migration
  def change
    create_table :user_follow_bcts do |t|
      t.references :user, index: true, foreign_key: true
      t.references :broadcaster, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
