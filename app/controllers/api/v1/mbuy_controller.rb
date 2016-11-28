class Api::V1::MbuyController < Api::V1::ApplicationController
  include Api::V1::Authorize
  include Api::V1::Mbuy

  before_action :authenticate

  def mbuy
    render plain: create_cp_transaction(params[:isdn], params[:amount])
  end
end
