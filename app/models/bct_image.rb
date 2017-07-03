class BctImage < ActiveRecord::Base
  belongs_to :broadcaster

  mount_uploader :image, PictureUploader

	validates :image, presence: true

	def image_path
		image = {}
		if !self.image.url.nil?
			image = {
					image: 						"#{Settings.base_url}#{self.image.url}", 
					image_w160h160: 	"#{Settings.base_url}#{self.image.w160h160.url}",
					image_w320h320: 	"#{Settings.base_url}#{self.image.w320h320.url}",
					image_w640h640: 	"#{Settings.base_url}#{self.image.w640h640.url}",
				}
		else
			image = {
					image: 						nil,
					image_w160h160: 	nil,
					image_w320h320: 	nil,
					image_w640h640: 	nil,
				}
		end
		return image
  	end
end
