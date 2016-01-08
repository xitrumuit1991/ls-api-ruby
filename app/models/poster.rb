class Poster < ActiveRecord::Base
	validates :title, :sub_title, :thumb, :link, :weight, presence: true

	mount_uploader :thumb, PosterUploader
end
