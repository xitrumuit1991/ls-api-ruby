module Megabanks
	class Service
		attr_accessor :respUrl, :merchantid, :issuerID, :send_key, :received_key, :txnAmount, :fee, :userName, :bankID, :soapClient, :responCodeConfirm, :transidConfirm
		def _deposit
			time 					= Time.now
			tranID 					= time.to_i.to_s + time.usec.to_s
			stan 					= time.to_i.to_s[4..time.to_i.to_s.length]
			termtxndatetime 		= DateTime.now.strftime('%Y%m%d%H%M%S')
			macData 				= merchantid + stan + termtxndatetime + txnAmount + fee + userName + issuerID + tranID + bankID + respUrl
			mac 					= mDESMAC_3des(macData, send_key)
			data 					= Hash.new
			data["merchantid"] 		= merchantid
			data["stan"] 			= stan
			data["termtxndatetime"] = termtxndatetime
			data["txnAmount"] 		= txnAmount
			data["fee"] 			= fee
			data["userName"] 		= userName
			data["IssuerID"] 		= issuerID
			data["tranID"] 			= tranID
			data["bankID"] 			= bankID
			data["mac"] 			= mac
			data["respUrl"] 		= respUrl
			begin
				result 					= soapClient.call(:deposit,  message: data )
				return result.body
			rescue
				return false
			end
		end

		def _confirm
			data 					= Hash.new
			data["merchantcode"] 	= merchantid.to_s
			data["txnAmount"]		= txnAmount.to_s
			data["confirmCode"] 	= responCodeConfirm.to_s
			data["tranid"] 			= transidConfirm.to_s
			macData					= data["merchantcode"] + data["tranid"] + data["txnAmount"] + data["confirmCode"]
			mac 					= mDESMAC_3des(macData, send_key)
			data["mackey"]				= mac
			begin
				result 				= soapClient.call(:comfirm,  message: data )
				return result.body
			rescue
				return false
			end
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