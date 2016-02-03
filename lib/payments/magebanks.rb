module Megabank
	class Service
		attr_accessor :respUrl, :merchantid, :issuerID, :send_key, :received_key, :txnAmount, :fee, :userName, :bankID, :soapClient
		def _deposit
			time 			= Time.now
			tranID 			= time.to_i.to_s + time.usec.to_s
			stan 			= time.to_i.to_s[4..time.to_i.to_s.length]
			termtxndatetime = DateTime.now.strftime('%Y%m%d%H%M%S')
			macData 		= merchantid + stan + termtxndatetime + txnAmount + fee + userName + issuerID + tranID + bankID + respUrl
			mac 			= mDESMAC_3des(macData, send_key)
			data 			= {"merchantid": merchantid, "stan": stan, "termtxndatetime": termtxndatetime, "txnAmount": txnAmount, "fee": fee, "userName": userName, "IssuerID": issuerID, "tranID": tranID , "bankID": bankID, "mac": mac, "respUrl": respUrl}
			result 			= soapClient.call(:deposit,  message: data )
			puts '=============data================'
			# puts merchantid
			# puts stan
			# puts termtxndatetime
			# puts txnAmount
			# puts fee
			# puts userName
			# puts issuerID
			# puts tranID
			# puts bankID
			# puts respUrl
			# puts time.strftime('%Y%m%d%H%M%S')
			# puts mac.length
			# puts mac
			puts data
			puts '=============data================'
			puts '=============mac================'
			puts result.body
			puts mac
			puts '=============mac================'
			return data
		end

		def confirm
			
		end

		def mDESMAC_3des(input, key)
			input 	= Digest::SHA1.hexdigest(input)
			len 	= input.length
			cipher 		= OpenSSL::Cipher::Cipher.new("des-ede3")
			cipher.encrypt
			cipher.key 	= key
			input = hex2bin(input)
			input += "\0" until input.bytesize % 8 == 0
			encrypted 	= cipher.update(input)
			macDes 		= encrypted.to_hex_string.gsub(" ",'')
			return macDes.upcase
		end

		def hex2bin(str)
			bin = ""
			i   = 0
			while i < str.length  do
				bin += (str[i]+str[i+1]).to_i(16).chr
				i = i + 2
			end
			return bin
		end
	end
end