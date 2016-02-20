class Card < ActiveRecord::Base
	validates :price, :coin, presence: true
end
