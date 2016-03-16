class BctAction < ActiveRecord::Base
  belongs_to :room
  belongs_to :room_action
end
