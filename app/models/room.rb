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
	has_many :screen_text_logs
	has_many :ban_users
	has_many :banned_users, through: :ban_users, class_name: 'User', foreign_key: 'user_id', source: :user

	validates :title, presence: true
	validates :slug, presence: true, uniqueness: true
	validates :room_type_id, presence: true
	mount_uploader :thumb, RoomThumbUploader
	mount_base64_uploader :thumb_crop, ThumbCropUploader

	def thumb_path(mobile = false)
		if mobile
			"#{Settings.base_url}/api/v1/rooms/#{self.id}/thumb_mb?timestamp=#{self.updated_at.to_i}"
		else
			"#{Settings.base_url}/api/v1/rooms/#{self.id}/thumb?timestamp=#{self.updated_at.to_i}"
		end
	end
end
