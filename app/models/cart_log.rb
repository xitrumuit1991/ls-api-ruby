class CartLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :provider
end
