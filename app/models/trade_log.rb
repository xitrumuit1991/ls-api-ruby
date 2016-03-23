class TradeLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :vip_package
end
