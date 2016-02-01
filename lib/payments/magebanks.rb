module Megabank
	class Service
		attr_accessor :respUrl, :merchantid, :issuerID, :send_key, :received_key, :txnAmount, :fee, :userName, :bankID, :soapClient
		def _deposit
			time 			= Time.now
			tranID 			= time.to_i.to_s + time.usec.to_s
			stan 			= time.to_i.to_s[4..time.to_i.to_s.length]
			termtxndatetime = DateTime.now.strftime('%Y%m%d%I%M%S')
			macData 		= merchantid + stan + termtxndatetime + txnAmount + fee + userName + issuerID + tranID + bankID + respUrl
			mac 			= mDESMAC_3des(macData, send_key)
			data 			= { :merchantid => merchantid, :stan => stan, :termtxndatetime => termtxndatetime, :txnAmount => txnAmount, :fee => fee, :userName => userName, :IssuerID => issuerID, :tranID => tranID , :bankID => bankID, :mac => mac, :respUrl => respUrl}
			puts '=============merchantid================'
			# puts merchantid
			# puts stan
			# puts termtxndatetime
			# puts txnAmount
			# puts fee
			# puts userName
			# puts issuerID
			# puts tranID
			# puts bankID
			puts mac.length
			puts mac
			# puts respUrl
			puts '=============merchantid================'
			return true
		end

		def confirm
			
		end

		def mDESMAC_3des(input, key)
			input 	= Digest::SHA1.hexdigest(input)[0,24]
			len 	= input.length
			# DES-EDE3
			# DES-EDE3-CBC
			# DES-EDE3-CFB
			# DES-EDE3-CFB1
			# DES-EDE3-CFB8
			# DES-EDE3-OFB
			cipher 		= OpenSSL::Cipher::Cipher.new("DES-EDE3-OFB")
			cipher.encrypt
			cipher.key 	= key
			encrypted 	= cipher.update(hex2bin(input))
			macDes 		= encrypted.to_hex_string.gsub(" ",'')
			puts '===========encrypted============'
			puts encrypted
			puts encrypted.length
			puts '===========encrypted============'
			return macDes.upcase
		end

		def hex2bin(str)
			bin = ""
			i   = 0
			while i < str.to_s.length  do
				bin += (str[i]+str[i+1]).to_i(16).chr
				i = i + 2
			end
			return bin
		end
	end
end