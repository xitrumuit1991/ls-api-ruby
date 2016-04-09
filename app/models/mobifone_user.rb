class MobifoneUser < ActiveRecord::Base
  belongs_to :user
	has_many :mobifone_user_vip_logs
end
