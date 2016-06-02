class RoomAction < ActiveRecord::Base
  belongs_to :bct_actions
  validates :name, :image, :price, :max_vote, :discount, presence: true

  mount_uploader :image,  RoomActionImageUploader

  def image_path
  	image = {}
		if !self.image.url.nil?
			image = {
					image: 		"#{Settings.base_url}#{self.image.url}", 
					image_w50h50: 	"#{Settings.base_url}#{self.image.w50h50.url}",
					image_w100h100:"#{Settings.base_url}#{self.image.w100h100.url}",
					image_w200h200:"#{Settings.base_url}#{self.image.w200h200.url}",
				}
		else
			image = {
					image: 			nil,
					image_w50h50: 		nil,
					image_w100h100: 	nil,
					image_w200h200: 	nil,
				}
		end
		return image
  end
end
