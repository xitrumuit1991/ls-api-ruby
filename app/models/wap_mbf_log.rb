class WapMbfLog < ActiveRecord::Base
	validates :trans_id, uniqueness: true
end
