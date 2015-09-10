class Api::V1::IndexController < Api::V1::ApplicationController
  include Api::V1::Authorize

  def index
    render plain: 'Livestar API Version 1.1.0'
  end
end