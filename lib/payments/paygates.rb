require 'nokogiri'
require 'ostruct'
require 'open-uri'

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
		def _login
			obj 		= Paygate::LoginResponse.new
			rSAClass 	= Paygate::ClsCryptor.new
			rSAClass.GetpublicKeyFrompemFile(File.join(Rails.root, 'lib', 'payments', 'key', 'Epay_Public_key.pem'))
			begin
				encrypedPass = rSAClass.encrypt($m_Pass);
			end

			pass = Base64.encode64(encrypedPass).gsub("\n",'')
			begin
				client = Savon.client(wsdl: $webservice)
				result = client.call(:login,  message: { :m_UserName => $m_UserName, :m_Pass => pass, :m_PartnerID => $m_PartnerID })
			rescue Exception => e
				return head 401
			end
			result = Nokogiri::XML.parse(result.to_s)
			page = result.at('multiRef')
			puts '===============message=================='
			puts page.at('sessionid').text
			puts '===============message=================='
		end
	end

	class LoginResponse
		$m_Status
		$m_Sessage
		$m_SessionID
		$m_TransID
	end

	class ClsCryptor
		def GetpublicKeyFromCertFile
		end

		def GetpublicKeyFrompemFile(filepath)
			@rsaPublicKey = OpenSSL::PKey::RSA.new(File.read(filepath))
		end

		def GetPrivatekeyFrompemFile
			
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

		def decrypt
			
		end

		private
			@rsaPublicKey
			@rsaPrivateKey
			@tripDesKey
	end
end