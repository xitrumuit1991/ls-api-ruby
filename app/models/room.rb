class Room < ActiveRecord::Base
  belongs_to :broadcaster
  belongs_to :room_type
  has_many :schedules

  validates :title, presence: true
  validates :room_type_id, presence: true
  mount_uploader :thumb, RoomThumbUploader
end
