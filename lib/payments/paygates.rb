require 'nokogiri'
require 'hex_string'

$m_PartnerID   	= "charging01"
$m_MPIN        	= "pajwtlzcb"
$m_UserName    	= "charging01"
$m_Pass        	= "gmwtwjfws"
$m_PartnerCode 	= "00477"
$webservice 	= "http://charging-test.megapay.net.vn:10001/CardChargingGW_V2.0/services/Services?wsdl"
# Ten tai khoan nguoi dung tren he thong doi tac
$m_Target 		= "useraccount1";
module Paygate
	class Login
		attr_accessor :m_UserName, :m_Pass, :m_PartnerID, :soapClient
		def _login
			$obj 		= Paygate::LoginResponse.new
			rSAClass 	= Paygate::ClsCryptor.new
			rSAClass.GetpublicKeyFrompemFile(File.join(Rails.root, 'lib', 'payments', 'key', 'Epay_Public_key.pem'))
			begin
				encrypedPass = rSAClass.encrypt(m_Pass);
			end

			pass = Base64.encode64(encrypedPass).gsub("\n",'')
			begin
				result = soapClient.call(:login,  message: { :m_UserName => m_UserName, :m_Pass => pass, :m_PartnerID => m_PartnerID })
			rescue Exception => e
				return head 401
			end
			puts '==============result================='
			puts result
			puts '==============result================='
			result = Nokogiri::XML.parse(result.to_s)
			page = result.at('multiRef')
			$obj.m_Sessage = page.at('message').text
			$obj.m_Status = page.at('status').text
			rSAClass.GetPrivatekeyFrompemFile(File.join(Rails.root, 'lib', 'payments', 'key', 'private_key.pem'))
			begin
				session_Decryped = rSAClass.decrypt(Base64.decode64(page.at('sessionid').text));
				$obj.m_SessionID = hextobyte(session_Decryped)
			rescue Exception => e
				return head 401
			end
			$obj.m_Sessage = page.at('transid').text
			return $obj;
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
		attr_accessor :m_Status, :m_Sessage, :m_SessionID, :m_TransID
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

		def _cardCharging
			login = Paygate::Login.new
			login.m_UserName	= m_UserName
			login.m_Pass		= m_Pass
			login.m_PartnerID	= m_PartnerID
			login.soapClient	= soapClient

			loginresponse      	= Paygate::LoginResponse.new
			loginresponse      	= login._login
			if loginresponse.m_Status == "1"
				sessionID 	= loginresponse.m_SessionID.to_hex_string.gsub(" ",'')
			else
				render plain: 'Login fail khong thuc hien charging', status: 400
			end
			#Bat dau thuc hien charging
			ojb = Paygate::CardChargingResponse.new
			key = hextobyte(sessionID);
			objTriptDes 		= Paygate::TriptDes.new
			objTriptDes.dessKey = key

			begin
				strEncreped = objTriptDes.encrypt(m_MPIN)
				mpin = byteToHex(strEncreped);
				card_DATA = byteToHex(objTriptDes.encrypt(m_Card_DATA));
			rescue Exception => e
			end

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

		# public function encrypt($text) {
		# 	$key       = $this->DessKey;
		# 	$text      = $this->pkcs5_pad($text, 8);// AES?16????????
		# 	$size      = mcrypt_get_iv_size(MCRYPT_3DES, MCRYPT_MODE_ECB);
		# 	$iv        = mcrypt_create_iv($size, MCRYPT_RAND);
		# 	$bin       = pack('H*', bin2hex($text));
		# 	$encrypted = mcrypt_encrypt(MCRYPT_3DES, $key, $bin, MCRYPT_MODE_ECB, $iv);
		# 	return $encrypted;
		# }

		def encrypt(text)
			key 	= dessKey
			text 	= pkcs5_pad(text, 8)
			cipher 	= OpenSSL::Cipher::Cipher.new("des-ede-cbc")
			iv 		= cipher.random_iv
			bin 	= text.to_hex_string.split(' ').pack('H*' * text.to_hex_string.split(' ').size)
			#xong den day roi 
			cipher.encrypt
			cipher.key = bin
			cipher.iv = iv
			encrypted = cipher.update(key) + cipher.final
			test = Base64.encode64(text).gsub("\n",'')
			puts '==========iv=========='
			puts dessKey
			puts '==========encrypted=========='
			puts encrypted
			puts '==========test=========='
			puts test
			puts '==========iv=========='
		end

		def pkcs5_pad(text, blocksize)
			pad = blocksize - (text.length%blocksize)
			return text + pad.chr*pad
		end
	end

	class CardChargingResponse
		attr_accessor :m_Status, :m_Message, :m_TRANSID, :m_AMOUNT, :m_RESPONSEAMOUNT
	end
end