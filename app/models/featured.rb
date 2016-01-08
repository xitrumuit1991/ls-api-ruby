class Featured < ActiveRecord::Base
  belongs_to :broadcaster

  validates :broadcaster_id, :weight, presence: true

end
