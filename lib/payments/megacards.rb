require 'hex_string'

module Megacard
	class MegacardAPIServices
		attr_accessor :m_ws_url, :m_partnerId, :m_cardSerial, :m_cardPin, :m_telcoCode, :m_targetAcc, :m_password
		def charging
			objResponse = Megacard::MegaCardChargingResponse.new
			url = m_ws_url
			url += "?method=verifyCard"
			url += "&partnerId=#{m_partnerId}"
			url += "&cardSerial=#{m_cardSerial}"
			url += "&cardPin=#{m_cardPin}"
			transId = get_transid()
			url += "&transId=#{transId}"
			url += "&telcoCode=#{m_telcoCode}"
			url += "&targetAcc=#{m_targetAcc}"
			url += "&password=#{Digest::MD5.hexdigest(m_password)}"
			url += "&signature=#{signature_hash(transId)}"
			res = parseHash(get_curl(url))
			Rails.logger.info "ANGCO DEBUG Response: #{url}"
			case res['status']
			when '00'
				objResponse.status	= 200
				objResponse.message = 'Nạp thẻ thành công.'
			when '01'
				objResponse.status 	= 400
				objResponse.message = 'Đối tác không tồn tại.'
			when '02'
				objResponse.status 	= 400
				objResponse.message = 'Sai chữ ký.'
			when '03'
				objResponse.status 	= 400
				objResponse.message = 'Sai mật khẩu.'
			when '04'
				objResponse.status 	= 400
				objResponse.message = 'Sai IP.'
			when '05'
				objResponse.status 	= 400
				objResponse.message = 'Nhà cung cấp không tồn tại.'
			when '06'
				objResponse.status 	= 400
				objResponse.message = 'Đối tác chưa được cấu hình gạch thẻ với nhà cung cấp này.'
			when '07'
				objResponse.status 	= 400
				objResponse.message = 'Đối tác bị khóa gạch thẻ với nhà cung cấp này.'
			when '08'
				objResponse.status 	= 400
				objResponse.message = 'Mã thẻ sai độ dài.'
			when '09'
				objResponse.status 	= 400
				objResponse.message = 'Mã thẻ sai format.'
			when '11'
				objResponse.status 	= 400
				objResponse.message = 'Hệ thống lỗi.'
			when '12'
				objResponse.status 	= 400
				objResponse.message = 'Trùng mã giao dịch.'
			when '14'
				objResponse.status 	= 400
				objResponse.message = 'TransId không đúng định dạng.'
			when '15'
				objResponse.status 	= 400
				objResponse.message = 'Đã có một giao dịch thành công với serial này.'
			when '16'
				objResponse.status 	= 400
				objResponse.message = 'Giao dịch thất bại do các nguyên nhân khác.'
			when '17'
				objResponse.status 	= 400
				objResponse.message = 'Kết nối tới hệ thống core lỗi.'
			when '18'
				objResponse.status 	= 400
				objResponse.message = 'Tham số truyền lên thiếu hoặc rỗng.'
			when '19'
				objResponse.status 	= 400
				objResponse.message = 'Mã giao dịch không tồn tại trên hệ thống.'
			when '4'
				objResponse.status 	= 400
				objResponse.message = 'kiểm tra lại mã thả ( mã lỗi với thẻ Vinaphone).'
			when '5'
				objResponse.status 	= 400
				objResponse.message = 'Liên hệ với VNPT EPAY để được trợ giúp.'
			when '9'
				objResponse.status 	= 400
				objResponse.message = 'Partner Khóa các giao dịch nạp tiền và thự hiện nạp lại sau 2 - 3 phút.'
			when '10'
				objResponse.status 	= 400
				objResponse.message = 'Partner Khóa các giao dịch nạp tiền và thự hiện nạp lại sau 2 - 3 phút.'
			when '11'
				objResponse.status 	= 400
				objResponse.message = 'Liên hệ với VNPT EPAY để được trợ giúp.'
			when '13'
				objResponse.status 	= 400
				objResponse.message = 'Hệ thống tạm thời bận, liên hệ với VNPT EPAY để được trợ giúp.'
			when '-2'
				objResponse.status 	= 400
				objResponse.message = 'Kiểm tra lại mã thẻ với nhà cung cấp.'
			when '-3'
				objResponse.status 	= 400
				objResponse.message = 'Kiểm tra lại hạn sử dụng của thẻ.'
			when '50'
				objResponse.status 	= 400
				objResponse.message = 'Kiểm tra lại mã thẻ đang sử dụng.'
			when '51'
				objResponse.status 	= 400
				objResponse.message = 'Kiểm tra lại seri cua thẻ đang sử dụng.'
			when '52'
				objResponse.status 	= 400
				objResponse.message = 'Kiểm tra lại serial và mã thẻ.'
			when '53'
				objResponse.status 	= 400
				objResponse.message = 'Kiểm tra lại serial và mã thẻ.'
			when '55'
				objResponse.status 	= 400
				objResponse.message = 'Sau 24h thẻ sẽ đươc kích hoạt lại.'
			when '56'
				objResponse.status 	= 400
				objResponse.message = 'Liên hệ với VNPT EPAY.'
			when '59'
				objResponse.status 	= 400
				objResponse.message = 'Kiểm tra lại mã thẻ với nhà cung cấp(thẻ Viettel).'
			when '65'
				objResponse.status 	= 400
				objResponse.message = 'Hoàn thành các kết nối khác hoặc đợi kết nối cũ được giải phóng để có thể tiếp tục thực hiện giao dich.'
			when '99'
				objResponse.status 	= 400
				objResponse.message = 'Liên hệ với VNPT EPAY để được trợ giúp.'
			when '66'
				objResponse.status 	= 400
				objResponse.message = 'Mã thẻ đã gửi một giao dịch thành công lên hệ thống.'
			when '67'
				objResponse.status 	= 400
				objResponse.message = 'Serial hoặc mã thẻ không đúng định dạng của hệ thống.'
			else
				objResponse.status 	= 400
				objResponse.message = 'Không nằm trong hệ thông lỗi.'
			end
			objResponse.transId = res['transId']
			objResponse.m_RESPONSEAMOUNT = res['realAmount']
			return objResponse;
		end

		def get_transid
			return "#{m_partnerId}_#{Time.now.strftime('%Y%m%d%H%M%S')}_#{rand(999)}"
		end
		
		def signature_hash transId
			return Digest::MD5.hexdigest("#{m_partnerId}&#{m_cardSerial}&#{m_cardPin}&#{transId}&#{m_telcoCode}&#{Digest::MD5.hexdigest(m_password)}")
		end

		def get_curl(url)
			str = Curl::Easy.http_get(url)
			Rails.logger.info "ANGCO DEBUG str: #{str}"
			return str.body_str
		end

		def parseHash response
			obj = {}
			response.split('&').each do |res|
				obj[res.split('=')[0]] = res.split('=')[1]
			end
			return obj
		end
	end
	class MegaCardChargingResponse
		attr_accessor :transId, :m_RESPONSEAMOUNT, :status, :message #:status return ra web
	end
end