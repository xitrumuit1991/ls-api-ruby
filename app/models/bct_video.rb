class BctVideo < ActiveRecord::Base
  include YoutubeHelper
  belongs_to :broadcaster
  mount_uploader :thumb, BctVideoThumbUploader

	validates :video, presence: true

	def thumb_path
		thumb = {}
		if !self.thumb.url.nil?
			thumb = {
				thumb: 			"#{Settings.base_url}#{self.thumb.url}",
				thumb_w190h108: 	"#{Settings.base_url}#{self.thumb.w190h108.url}",
				thumb_w380h216: 	"#{Settings.base_url}#{self.thumb.w380h216.url}",
				thumb_w760h432: 	"#{Settings.base_url}#{self.thumb.w760h432.url}"
			}
		else
			video_id = youtubeID(self.video)
			thumb = {
				thumb: 			"http://img.youtube.com/vi/#{video_id}/hqdefault.jpg",
				thumb_w190h108: 	"http://img.youtube.com/vi/#{video_id}/default.jpg",
				thumb_w380h216: 	"http://img.youtube.com/vi/#{video_id}/mqdefault.jpg",
				thumb_w760h432: 	"http://img.youtube.com/vi/#{video_id}/sddefault.jpg"
			}
		end
	end
end
