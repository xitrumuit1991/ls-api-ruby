module Ebaysms
	class Sms
		attr_accessor :partnerid, :moid, :userid, :shortcode, :keyword, :content, :transdate, :checksum, :amount, :smspPartnerPassword, :partnerpass

		def getMOChecksum
			return Digest::MD5.hexdigest (moid + shortcode + keyword + content.tr_s(' ', '+') + transdate + partnerpass)
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
			mt_content  = 'Ban+da+nap+thanh+cong+' + amount + '+xu+vao+tai+khoan+tai+website+livestar.vn'
			url         += '&content=' + mt_content
			url         += '&messagetype=1'
			url         += '&totalmessage=1'
			url         += '&messageindex=1'
			url         += '&ismore=0'
			url         += '&contenttype=0'
			mt_transdate= DateTime.now.strftime('%Y%m%d%I%M%S')
			url         += '&transdate=' + mt_transdate
			# url         += '&checksum=' + Digest::MD5.hexdigest(mtid + moid  + shortcode + keyword + mt_content  + mt_transdate + Digest::MD5.hexdigest(partnerpass))
			url         += '&checksum=' + Digest::MD5.hexdigest(mtid + moid  + shortcode + keyword + mt_content  + mt_transdate + partnerpass)
			url         += '&amount=' + amount
			puts '=========confirm url=========='
			puts url
			puts '=========confirm url=========='
			return url
		end

		def confirm
			url = getUrl
			str = Curl::Easy.perform('http://api.livestar.vn/api/v1/users/username_1')
			return str.body_str
		end
	end
end