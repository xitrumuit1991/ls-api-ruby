class AddFacebookTwitterInstagramLinkToUsers < ActiveRecord::Migration
  def change
    add_column :users, :instagram_link, :string, after: :cover
    add_column :users, :twitter_link, :string, after: :cover
    add_column :users, :facebook_link, :string, after: :cover
  end
end
