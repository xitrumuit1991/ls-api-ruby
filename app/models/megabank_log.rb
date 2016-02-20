class MegabankLog < ActiveRecord::Base
  belongs_to :bank
  belongs_to :megabank
  belongs_to :user
end
