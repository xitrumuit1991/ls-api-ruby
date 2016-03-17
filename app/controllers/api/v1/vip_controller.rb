class Api::V1::VipController < Api::V1::ApplicationController
  include Api::V1::Authorize
  before_action :authenticate

  def buyVip
    puts '========================'
    puts params[:vip_package_id]
    puts @user
    puts '========================'
    render json: {error: "Vip không tồn tại!"}, status: 400
  end
end