class RoomType < ActiveRecord::Base
	validates :title, :slug, :description, presence: true
end
