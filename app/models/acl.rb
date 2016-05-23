class Acl < ActiveRecord::Base
  belongs_to :role
  belongs_to :resource
end
