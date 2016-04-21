class CoinLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :coin
end
