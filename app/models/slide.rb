class Slide < ActiveRecord::Base
	validates :title, :description, :sub_description, :weight, :banner, presence: true

	mount_uploader :banner, SlideUploader

	def banner_path
		# logger.info("---------model slide:")
		# logger.info("---------Settings.base_url:")
		# logger.info("---------Settings.base_url:")
		# logger.info(Settings.base_url) 
		# logger.info("---------model slide:")
		# logger.info("---------self.banner.url:")
		# logger.info("---------self.banner.url:")
		# logger.info(self.banner.url) 
  		banner = {}
		if !self.banner.url.nil?
			banner = {
				banner: 						"#{Settings.base_url}#{self.banner.url}", 
				banner_w1200h480: 	"#{Settings.base_url}#{self.banner.w1200h480.url}",
				banner_w170h120: 		"#{Settings.base_url}#{self.banner.w170h120.url}",
				}
		else
			banner = {
				banner: 						nil,
				banner_w1200h480: 	nil,
				banner_w170h120: 		nil,
				}
		end
		return banner
  	end

	rails_admin do
		configure :banner, :jcrop
		list do
			field :title do 
				label "Tiêu đề"
			end
			field :description do
				sortable false
				label "Mô tả"
		    end
			field :sub_description do
				sortable false
				label "Mô tả thêm"
		    end
			field :weight do
				label "Thứ tự"
		    end
			field :banner do
				sortable false
				label "Hình Ảnh (1155 x 462)"
		    end
		end
		edit do 
			field :title do
				label "Tiêu đề"
		    end

		    field :description do
				label "Mô tả"
		    end

		    field :sub_description do
				label "Mô tả thêm"
		    end

		    field :start_time do
				label "Bắt đầu"
		    end

		    field :link do
				label "Link liên kết"
		    end

		    field :banner do
				label "Hình Ảnh"
        		jcrop_options aspectRatio: 1155.0/462.0
        		help 'Hình Ảnh (1155 x 462)'
		    end

		    field :weight do
				label "Thứ tự"
		    end
		end
	end
end
