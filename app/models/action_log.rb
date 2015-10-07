class ActionLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :room
  belongs_to :room_action
end
