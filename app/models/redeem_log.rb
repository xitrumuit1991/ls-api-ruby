class RedeemLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :redeem
end
