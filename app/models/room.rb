class Room < ActiveRecord::Base
  belongs_to :broadcaster
  belongs_to :room_type
end
