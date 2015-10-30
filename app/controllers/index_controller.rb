class IndexController < ApplicationController
  def index
    render plain: 'Livestar v1'
  end
end