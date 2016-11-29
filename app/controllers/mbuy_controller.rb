class MbuyController < ApplicationController
  before_filter :filter_ip

  soap_service namespace: 'http://services.cp/'

  soap_action 'receiveChargingResult',
    args: { command: :string, cpCode: :string, ContentCode: :string, totalAmount: :string, account: :string, isdn: :string, result: :string },
    return: { receiveChargingResultResult: :string }

  def receiveChargingResult
    if params[:totalAmount].present? && params[:isdn].present? && params[:result].present?
      isdn = params[:isdn]
      isdn = '84' + isdn[1..isdn.length]
      money =  params[:totalAmount].to_i * 0.008
      result_parts = params[:result].split('|')

      mbuy_request = MbuyRequest.create(command: params[:command], cp_code: params[:cpCode], content_code: params[:ContentCode], total_amount: params[:totalAmount], account: params[:account], isdn: params[:isdn], result: params[:result])

      if result_parts[1].present? && result_parts[1] == 'MPAY-0000'
        transaction = MbuyTransaction.find_by_trans_id(trans_id: result_parts[0])
        if transaction.present?
          new_money = user.money + money.to_i;
          if transaction.user.update(money: new_money)
            mbuy_request.update(total_final: money)
            transaction.update(status: 1)
            render soap: { receiveChargingResultResult: 'Cong tien thanh cong'} and return
          else
            render soap: { receiveChargingResultResult: 'Khong the cong tien, vui long lien he ky thuat vien' } and return
          end
        else
          render soap: { receiveChargingResultResult: 'Transaction khong ton tai'} and return
        end
      else
        user = User.find_by_active_code(params[:account])
        if user.present?
          transaction = MbuyTransaction.create(isdn: isdn, total_amount: params[:totalAmount], checksum: money, user_id: user.id, status: 0)
          new_money = user.money + money.to_i;
          if user.update(money: new_money)
            mbuy_request.update(total_final: money)
            transaction.update(status: 1)
            render soap: { receiveChargingResultResult: 'Cong tien thanh cong'} and return
          else
            render soap: { receiveChargingResultResult: 'Khong the cong tien, vui long lien he ky thuat vien' } and return
          end
        else
          render soap: { receiveChargingResultResult: "Account khong ton tai" } and return
        end
      end
    else
      render soap: { receiveChargingResultResult: "Khong the cong tien, vui long lien he ky thuat vien" } and return
    end
  end

  def filter_ip
    puts request.remote_ip
  end
end