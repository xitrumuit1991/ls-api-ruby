module Ebaysms
	class Sms
		attr_accessor :partnerid, :moid, :userid, :shortcode, :keyword, :content, :transdate, :checksum, :amount, :smspPartnerPassword

		def encode
			
		end
		
		def getMOChecksum
			puts '======================'
			puts Digest::MD5.hexdigest (moid + shortcode + keyword + content.tr_s(' ', '+') + transdate + "37c91f0c15547ddc2fdb6a6d126f8590")
			puts '======================'
			return Digest::MD5.hexdigest (moid + shortcode + keyword + content.tr_s(' ', '+') + transdate + "37c91f0c15547ddc2fdb6a6d126f8590")
		end

		def _checksum
			if getMOChecksum == checksum
				return true
			else
				return false
			end
		end

		def mtid
			
		end

		def getMTPayload
			
		end

		def getMTPath
			
		end

		def sendMT
			
		end
	end
end