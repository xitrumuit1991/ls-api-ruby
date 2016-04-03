class MobifoneUserVipLog < ActiveRecord::Base
  belongs_to :mobifone_user
  belongs_to :user_has_vip_package
end
