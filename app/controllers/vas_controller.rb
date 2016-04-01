class VasController < ApplicationController
  before_filter :dump_parameters

  soap_service namespace: 'urn:livestar'

  soap_action 'buy_vip_package',
              args:   { username: :string, package_code: :string },
              return: :string

  def buy_vip_package
    puts ""
    puts params[:username]
    render soap: true
  end

  def dump_parameters
    Rails.logger.debug params.inspect
  end
end