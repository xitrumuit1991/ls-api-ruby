class Poster < ActiveRecord::Base
	validates :title, :sub_title, :thumb, :link, :weight, presence: true
	validates :weight, numericality: { only_integer: true }

	mount_uploader :thumb, PosterUploader
end
