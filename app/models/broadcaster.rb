class Broadcaster < ActiveRecord::Base
  belongs_to :user
  belongs_to :bct_type
  belongs_to :broadcaster_level
  has_many :images, class_name:'BctImage'
  has_many :videos, class_name:'BctVideo'
end
