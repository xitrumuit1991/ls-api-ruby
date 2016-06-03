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
	has_many :bct_gifts
	has_many :bct_actions
	has_many :user_logs
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

	def thumb_path
		thumb = {}
		if !self.thumb_crop.url.nil?
			thumb = {
					thumb: 		"#{Settings.base_url}#{self.thumb_crop.url}", 
					thumb_w160h190: 	"#{Settings.base_url}#{self.thumb_crop.w160h190.url}",
					thumb_w240h135: 	"#{Settings.base_url}#{self.thumb_crop.w240h135.url}",
					thumb_w320h180: 	"#{Settings.base_url}#{self.thumb_crop.w320h180.url}",
					thumb_w720h405: 	"#{Settings.base_url}#{self.thumb_crop.w720h405.url}",
					thumb_w768h432: 	"#{Settings.base_url}#{self.thumb_crop.w768h432.url}",
					thumb_w960h540: 	"#{Settings.base_url}#{self.thumb_crop.w960h540.url}",
				}
		else
			thumb = {
					thumb: 			"#{Settings.base_url}default/no-thum-room.png",
					thumb_w160h190: 	"#{Settings.base_url}default/w160h190_no-thum-room.png",
					thumb_w240h135: 	"#{Settings.base_url}default/w240h135_no-thum-room.png",
					thumb_w320h180: 	"#{Settings.base_url}default/w320h180_no-thum-room.png",
					thumb_w720h405: 	"#{Settings.base_url}default/w720h405_no-thum-room.png",
					thumb_w768h432: 	"#{Settings.base_url}default/w768h432_no-thum-room.png",
					thumb_w960h540: 	"#{Settings.base_url}default/w960h540_no-thum-room.png",
				}
		end
		return thumb
		# "#{Settings.base_url}/api/v1/users/#{self.id}/avatar?timestamp=#{self.updated_at.to_i}"
	end
end
