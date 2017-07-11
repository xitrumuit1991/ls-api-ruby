module Ebaysms
	class Sms
		attr_accessor :partnerid, :moid, :userid, :shortcode, :telcocode, :keyword, :content, :transdate, :checksum, :amount, :partnerpass

		def getMOChecksum
			#checkSum = MD5(moid + shortcode + keyword + UrlEncode(content) + transdate + partnerpass)
			return Digest::MD5.hexdigest(moid + shortcode + keyword + content.tr_s(' ', '+') + transdate + partnerpass)
		end

		def _checksum
			if getMOChecksum == checksum
				return true
			else
				return false
			end
		end

		def getUrl
			url         ='http://sms.megapayment.net.vn:9099/smsApi?'
			url         += 'partnerid=' + partnerid
			url         += '&moid=' + moid
			mtid        = partnerid +  DateTime.now.strftime("%Y%m%d%I%M") + rand(0..99999).to_s;
			url         += '&mtid=' + mtid
			url         += '&userid=' + userid
			url         += '&receivernumber=' + userid
			url         += '&shortcode=' + shortcode
			url         += '&keyword=' + keyword
			mt_content  = 'Ban+da+nap+thanh+cong+' + amount + '+vnd+vao+ma+tai+khoan+'+keyword+'+tren+website+livestar.vn'
			url         += '&content=' + mt_content
			url         += '&messagetype=1'
			url         += '&totalmessage=1'
			url         += '&messageindex=1'
			url         += '&ismore=0'
			url         += '&contenttype=0'
			mt_transdate= DateTime.now.strftime('%Y%m%d%I%M%S')
			url         += '&transdate=' + mt_transdate
			url         += '&checksum=' + Digest::MD5.hexdigest(mtid + moid  + shortcode + keyword + mt_content  + mt_transdate + partnerpass)
			url         += '&amount=' + amount
			Rails.logger.info "ANGCO DEBUG URL: #{url}"
			return url
		end

		def confirm
			url = getUrl
			str = Curl::Easy.perform(url)
			Rails.logger.info "ANGCO DEBUG confirm_str: #{str}"
			return str.body_str
		end
	end
end