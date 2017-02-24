class Notification < ActiveRecord::Base
  belongs_to :room
  belongs_to :admin
end
