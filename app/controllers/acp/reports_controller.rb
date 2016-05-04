class Acp::ReportsController < Acp::ApplicationController

  def index
    @data = Room::all
  end

end