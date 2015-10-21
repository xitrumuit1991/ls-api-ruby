class Poster < ActiveRecord::Base
	mount_uploader :thumb, PosterUploader
end
