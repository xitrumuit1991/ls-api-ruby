class MbuyController < ApplicationController
  before_filter :filter_ip

  soap_service namespace: 'http://services.cp/'

  soap_action 'receiveChargingResult',
    args: { command: :string, cpCode: :string, ContentCode: :string, totalAmount: :string, account: :string, isdn: :string, result: :string },
    return: { receiveChargingResultResult: :string }

  def receiveChargingResult
    if params[:totalAmount].present? && params[:isdn].present? && params[:result].present?
      isdn = params[:isdn]
      money =  params[:totalAmount].to_i * 0.008
      result_parts = params[:result].split('|')

      MbuyRequest.create(command: params[:command], cp_code: params[:cpCode], content_code: params[:ContentCode], total_amount: params[:totalAmount], account: params[:account], isdn: params[:isdn], result: params[:result])

      if result_parts[1].present? && result_parts[1] == 'MPAY-0000'
        user = User.find_by_phone(isdn)
        if user.present?
          new_money = user.money + money.to_i;
          if user.update(money: new_money)
            render soap: { receiveChargingResultResult: 'Cong tien thanh cong'} and return
          else
            render soap: { receiveChargingResultResult: 'Khong the cong tien, vui long lien he ky thuat vien' } and return
          end
        else
          render soap: { receiveChargingResultResult: "So dien thoai #{isdn} khong ton tai" } and return
        end
      end
      render soap: { receiveChargingResultResult: "" } and return
    else
      render soap: { receiveChargingResultResult: "Khong the cong tien, vui long lien he ky thuat vien" } and return
    end
  end

  def filter_ip
    puts request.remote_ip
  end
end