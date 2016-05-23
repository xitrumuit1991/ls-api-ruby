class Role < ActiveRecord::Base
	has_many :acls
end
