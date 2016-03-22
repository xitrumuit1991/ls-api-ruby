class VipPackage < ActiveRecord::Base
  belongs_to :vip

  validates :vip_id, :name, :code, :no_day, :price, :discount, presence: true
end
