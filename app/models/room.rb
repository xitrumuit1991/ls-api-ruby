class Room < ActiveRecord::Base
	belongs_to :broadcaster
	belongs_to :room_type
	belongs_to :room_background
	belongs_to :broadcaster_background
	has_many :schedules
	has_many :heart_logs
	has_many :action_logs
	has_many :gift_logs
	has_many :lounge_logs

	validates :title, presence: true
	validates :room_type_id, presence: true
	mount_uploader :thumb, RoomThumbUploader
end
