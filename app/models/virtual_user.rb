class VirtualUser < ActiveRecord::Base
	mount_uploader :avatar, VirtualUserAvatarUploader
end
