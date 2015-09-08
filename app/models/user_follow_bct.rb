class UserFollowBct < ActiveRecord::Base
  belongs_to :user
  belongs_to :broadcaster
end
