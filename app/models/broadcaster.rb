class Broadcaster < ActiveRecord::Base
  belongs_to :user
  belongs_to :bct_type
  belongs_to :broadcaster_level
  has_many :photos
  has_many :videos
end
