class Poster < ActiveRecord::Base
	validates :title, :sub_title, :thumb, :link, :weight, presence: true

	mount_uploader :thumb, PosterUploader

	def thumb_path
  	thumb = {}
		if !self.thumb.url.nil?
			thumb = {
					thumb: 		"#{Settings.base_url}#{self.thumb.url}", 
					thumb_w180h480: 	"#{Settings.base_url}#{self.thumb.w180h480.url}",
					thumb_w360h960: 	"#{Settings.base_url}#{self.thumb.w360h960.url}",
				}
		else
			thumb = {
					thumb: 			nil,
					thumb_w180h480: 	nil,
					thumb_w360h960: 	nil,
				}
		end
		return thumb
  end
end
