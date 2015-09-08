class Broadcaster < ActiveRecord::Base
  belongs_to :user
  belongs_to :bct_type
  belongs_to :broadcaster_level
end
