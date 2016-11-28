class IndexController < ApplicationController
  include Api::V1::Mbuy
  
  protect_from_forgery :except => [:create_transaction_mbuy]

  def index
    render plain: 'Livestar v1'
  end


  def mbuy
  	render layout: false
  end

  def create_transaction_mbuy
    render plain: create_cp_transaction(params[:isdn], params[:amount])
  end
end