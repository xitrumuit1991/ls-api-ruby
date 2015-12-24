class HomeFeatured < ActiveRecord::Base
  belongs_to :broadcaster

  validates :broadcaster_id, :presence => {:message => 'Vui lòng chọn broadcaster'}
  validates :weight, :presence => {:message => 'Vui lòng nhập '}, numericality: { only_integer: true, :message => 'Chỉ nhập số' }
end
