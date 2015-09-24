class Api::V1::BroadcastersController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate
  before_action :checkIsBroadcaster

  def profile
  end

  def status
    if @user.statuses.create(content: params[:status])
      return head 200
    else
      render plain: 'System error !', status: 400
    end
  end

  private
    def checkIsBroadcaster
      unless @user.is_broadcaster
        return head 400
      end
    end

end
