class BctGift < ActiveRecord::Base
  belongs_to :room
  belongs_to :gift
end
