class HomeFeatured < ActiveRecord::Base
  belongs_to :broadcaster

  validates :broadcaster_id, :weight, presence: true

end
