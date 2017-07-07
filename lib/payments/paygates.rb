require 'hex_string'

module Paygate
	class Login
		attr_accessor :m_UserName, :m_Pass, :m_PartnerID, :soapClient
		def _login
			obj 		= Paygate::LoginResponse.new
			rSAClass 	= Paygate::ClsCryptor.new
			rSAClass.GetpublicKeyFrompemFile(File.join(Rails.root, 'lib', 'payments', 'key', 'public_key.pem'))
			begin
				encrypedPass = rSAClass.encrypt(m_Pass);
			end
			pass = Base64.encode64(encrypedPass).gsub("\n",'')
			begin
				#thuc hien login qua SOAP
				result = soapClient.call(:login,  message: { :m_UserName => m_UserName, :m_Pass => pass, :m_PartnerID => m_PartnerID })
			rescue Exception => e
				Rails.logger.info('---------class Login; _login Exception => e 111--------');
				Rails.logger.info(e);
				obj.status 	= 400
				obj.message 	= e
				return obj
			end
			Rails.logger.info('---------class Login; _login result--------');
			Rails.logger.info(result);
			hashData = Hash.from_xml(result.to_s);
			Rails.logger.info('---------hashData result =--------');
			Rails.logger.info(hashData);
			obj.m_Sessage = result.body[:multi_ref][:message]
			obj.m_Status = result.body[:multi_ref][:status]
			obj.m_TransID = result.body[:multi_ref][:transid]
			Rails.logger.info("---result.body[:multi_ref][:sessionid]=#{result.body[:multi_ref][:sessionid]}");
			if result.body[:multi_ref][:status] == "1"
				rSAClass.GetPrivatekeyFrompemFile(File.join(Rails.root, 'lib', 'payments', 'key', 'private_key.pem'))
				begin
					session_Decryped = rSAClass.decrypt(Base64.decode64(result.body[:multi_ref][:sessionid]))
					Rails.logger.info("rSAClass.decrypt; m_SessionID=#{session_Decryped} ");
					obj.m_SessionID = hextobyte(session_Decryped)
					Rails.logger.info("hextobyte(session_Decryped); m_SessionID=#{hextobyte(session_Decryped)} ");
				rescue Exception => e
					Rails.logger.info('---------_login Exception => e 222--------');
					Rails.logger.info(e);
					obj.status 	= 400
					obj.message 	= "_login : Không thể giải mã."
					return obj
				end
			else
				obj.m_SessionID = result.body[:multi_ref][:sessionid]
			end
			if result.body[:multi_ref][:status] == "1"
				obj.message 	= "Đăng nhập thành công SOAP."
				obj.status 	= 200
			else
				obj.message 	= "Đăng nhập không thành công SOAP."
				obj.status 	= 400
			end
			return obj
		end

		
		def hextobyte(strHex)
			string = ''
			i = 0
			while i < strHex.to_s.length - 1  do
				string += (strHex[i]+strHex[i+1]).to_i(16).chr
				i = i + 2
			end
			return string
		end
	end

	class LoginResponse
		attr_accessor :m_Status, :m_Sessage, :m_SessionID, :m_TransID, :status, :message
	end

	class ClsCryptor
		def GetpublicKeyFromCertFile
		end

		def GetpublicKeyFrompemFile(filepath)
			@rsaPublicKey = OpenSSL::PKey::RSA.new(File.read(filepath))
		end

		def GetPrivatekeyFrompemFile(filepath)
			@rsaPrivateKey = OpenSSL::PKey::RSA.new(File.read(filepath))
		end

		def GetPrivate_Public_KeyFromPfxFile
			
		end

		def encrypt(source)
			pub_key = @rsaPublicKey
			j=0
			i=0
			y = (source.length/10.0).floor.to_i
			crt = ''
			while i < y  do
				crypttext = ''
				source[y,10]
				crypttext = pub_key.public_encrypt(source[j,10].to_s)
				crt += crypttext
				crt += ":::";
				j = j+10
				i = i+1
			end
			if source.length%10 > 0
				crypttext = pub_key.public_encrypt(source[j,source.length].to_s)
				crt += crypttext
			end
			return crt
		end

		def decrypt(crypttext)
			priv_key = @rsaPrivateKey
			tt = crypttext.to_s.split(":::")
			cnt = tt.length
			i = 0;
			str = '';
			while i < cnt  do
				str1 = priv_key.private_decrypt(tt[i])
				str += str1
				i = i+1
			end
			return str1
		end

		private
			@rsaPublicKey
			@rsaPrivateKey
			@tripDesKey
	end

	class CardCharging
		attr_accessor :m_WebUser, :m_TransID, :m_UserName, :m_PartnerID, :m_MPIN, :m_Target, :m_Card_DATA, :m_Pass, :sessionID, :soapClient

		def cardCharging
			login = Paygate::Login.new
			ojb = Paygate::CardChargingResponse.new
			login.m_UserName	= m_UserName
			login.m_Pass			= m_Pass
			login.m_PartnerID	= m_PartnerID
			login.soapClient	= soapClient
			Rails.logger.info('---------Paygate login; create instance login--------');
			Rails.logger.info("m_UserName: #{login.m_UserName}");
			Rails.logger.info("m_Pass: #{login.m_Pass}");
			Rails.logger.info("m_PartnerID: #{login.m_PartnerID}");

			loginresponse      	= Paygate::LoginResponse.new
			loginresponse      	= login._login #thuc hien login megacard
			Rails.logger.info('---------Paygate loginresponse; process login cctCard--------');
			Rails.logger.info("loginresponse; status: #{loginresponse.status}");
			Rails.logger.info("loginresponse; message: #{loginresponse.message}");
			Rails.logger.info("loginresponse; m_Status: #{loginresponse.m_Status}");
			Rails.logger.info("loginresponse; m_Sessage: #{loginresponse.m_Sessage}");
			Rails.logger.info("loginresponse; m_SessionID: #{loginresponse.m_SessionID}");
			Rails.logger.info("loginresponse; m_TransID: #{loginresponse.m_TransID}");

			sessionID = nil
			if loginresponse.present? and loginresponse.status != 200
				Rails.logger.info('---------ERROR cardCharging login ; loginresponse.status != 200--------');
				ojb.megaCardResponse = loginresponse
				ojb.message 	= loginresponse.message
				ojb.status 		= 400
				return ojb
			end

			if loginresponse.present? and loginresponse.status == 200
				if loginresponse.m_Status == "1"
					Rails.logger.info('-----------SUCCESS cardCharging; login SOAP thanh cong; Paygate-----------');
					Rails.logger.info("m_SessionID: #{loginresponse.m_SessionID}");
					sessionID 	= loginresponse.m_SessionID.to_hex_string.gsub(" ",'')
					Rails.logger.info("sessionID: #{sessionID}");
				else
					Rails.logger.info('---------cardCharging login ERROR; loginresponse.m_Status != "1"--------');
					ojb.megaCardResponse = loginresponse
					ojb.status 		= 400
					ojb.message 	= "Không thể đăng nhập vào SOAP service vì sai tài khoản vui lòng cập nhật lại tài khoản !!! Xin cảm ơn."
					return ojb
				end
			end

			Rails.logger.info("---------Bat dau thuc hien charging----------");
			Rails.logger.info("---------Bat dau thuc hien charging----------");
			Rails.logger.info("---------Bat dau thuc hien charging----------");
			key = hextobyte(sessionID);
			Rails.logger.info("---------key=#{key}----------");
			objTriptDes 		= Paygate::TriptDes.new
			objTriptDes.dessKey = key
			begin
				strEncreped = objTriptDes.encrypt(m_MPIN)
				mpin = byteToHex(strEncreped);
				card_DATA = byteToHex(objTriptDes.encrypt(m_Card_DATA))
			rescue Exception => e
				Rails.logger.info("---------ERROR objTriptDes.encrypt(m_MPIN); error=#{e}----------");
				ojb.message 	= "Có lỗi khi mã hóa mã thẻ. Vui lòng thử lại lần nữa."
				ojb.status 		= 400
				return ojb
			end
			begin
				result = soapClient.call(:card_charging,  message: { :m_TransID => m_TransID, :m_UserName => m_UserName, :m_PartnerID => m_PartnerID, :m_MPIN => mpin, :m_Target => m_Target, :m_Card_DATA => card_DATA, :SessionID => Digest::MD5.hexdigest(sessionID) })
				Rails.logger.info("---------SUCCESS soapClient.call(:card_charging;...) result=#{result}----------");
				hashData = Hash.from_xml(result.to_s);
				Rails.logger.info('---------Hash DATA--------');
				Rails.logger.info(hashData);
			rescue Exception => e
				Rails.logger.info("---------ERROR soapClient.call(:card_charging...); error=#{e}----------");
				ojb.message 	= "Có lỗi khi thực hiện nạp thẻ. Vui lòng thử lại lần nữa."
				ojb.status 		= 400
				return ojb
			end
			if result.body[:multi_ref][:status] == "1"
				Rails.logger.info("---------SUCCESS charge----------");
				Rails.logger.info("---------m_Message=#{result.body[:multi_ref][:message]}----------");
				Rails.logger.info("---------m_AMOUNT=#{result.body[:multi_ref][:amount]}----------");
				Rails.logger.info("---------m_TRANSID=#{result.body[:multi_ref][:transid]}----------");
				Rails.logger.info("---------m_Status=#{result.body[:multi_ref][:status]}----------");
				Rails.logger.info("---------m_RESPONSEAMOUNT=#{result.body[:multi_ref][:responseamount]}----------");
				ojb.m_Message			= result.body[:multi_ref][:message]
				ojb.m_AMOUNT 			= result.body[:multi_ref][:amount]
				ojb.m_TRANSID 			= result.body[:multi_ref][:transid]
				ojb.m_Status 			= result.body[:multi_ref][:status]
				ojb.m_RESPONSEAMOUNT 	= objTriptDes.decrypt(hextobyte(result.body[:multi_ref][:responseamount]))
				ojb.message 			= "Nạp thẻ thành công."
				ojb.status 				= 200
				if ojb.m_Status == "3" or ojb.m_Status == "7"
					sessionID = nil
				end
			elsif result.body[:multi_ref][:status] == "50"
				ojb.message 	= "Thẻ đã được sử dụng hay không tồn tại."
				ojb.status 		= 400
			elsif result.body[:multi_ref][:status] == "51"
				ojb.message 	= "Mã số thẻ không xác thực"
				ojb.status 		= 400
			elsif result.body[:multi_ref][:status] == "52"
				ojb.message 	= "Mã số thẻ và serial không khớp."
				ojb.status 		= 400
			elsif result.body[:multi_ref][:status] == "53"
				ojb.message 	= "Mã số thẻ và serial không đúng."
				ojb.status 		= 400
			elsif result.body[:multi_ref][:status] == "55"
				ojb.message 	= "Thẻ bị khóa trong 24 tiếng đồng hồ"
				ojb.status 		= 400
			elsif result.body[:multi_ref][:status] == "4"
				ojb.message 	= "Mã thẻ không hợp lệ."
				ojb.status 		= 400
			else
				ojb.message 	= "Lỗi chưa xác định."
				ojb.status 		= 400
			end
			return ojb
		end

		def hextobyte(strHex)
			string = ''
			i = 0
			while i < strHex.to_s.length - 1  do
				string += (strHex[i]+strHex[i+1]).to_i(16).chr
				i = i + 2
			end
			return string
		end
		def byteToHex(strHex)
			return strHex.to_hex_string.gsub(" ",'')
		end
	end

	class TriptDes
		# chinh lai private
		attr_accessor :dessKey
		def triptDes(key)
			dessKey = key
		end

		def decrypt(text)
			begin
				key 		= dessKey
				cipher 		= OpenSSL::Cipher::Cipher.new("DES-EDE3")
				cipher.decrypt
				cipher.key 	= key
				decrypted = cipher.update(text) + cipher.final
				return pkcs5_unpad(decrypted)
			rescue Exception => e
				return false
			end
		end

		def encrypt(text)
			key 	= dessKey
			text 	= pkcs5_pad(text, 8)
			cipher 	= OpenSSL::Cipher::Cipher.new("DES-EDE3")
			iv 		= cipher.random_iv
			bin 	= text.to_hex_string.split(' ').pack('H*' * text.to_hex_string.split(' ').size)
			cipher.encrypt
			cipher.key = key
			cipher.iv = iv
			encrypted = cipher.update(bin)
			return encrypted
		end

		def pkcs5_pad(text, blocksize)
			pad = blocksize - (text.length%blocksize)
			return text + pad.chr*pad
		end

		def pkcs5_unpad(text)
			return text.gsub(" ",'')
		end
	end

	class CardChargingResponse
		attr_accessor :m_Status, :m_Message, :m_TRANSID, :m_AMOUNT, :m_RESPONSEAMOUNT, :status, :message, :megaCardResponse #:status return ra web
	end
end