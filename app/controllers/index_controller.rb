class IndexController < ApplicationController
  include Api::V1::Mbuy
  
  protect_from_forgery :except => [:create_transaction_mbuy]

  def index
    render plain: 'Livestar v1'
  end
end