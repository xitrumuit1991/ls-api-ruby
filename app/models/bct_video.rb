class BctVideo < ActiveRecord::Base
  belongs_to :broadcaster

  mount_uploader :thumb, BctVideoThumbUploader

	validates :video, :thumb, presence: true
end
