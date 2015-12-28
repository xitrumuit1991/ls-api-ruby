class Slide < ActiveRecord::Base
	validates :title, :description, :sub_description, :weight, :banner, presence: true
	validates :weight, numericality: {only_integer: true }

	mount_uploader :banner, SlideUploader

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
