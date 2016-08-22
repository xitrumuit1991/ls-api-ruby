module Api::V1::Wap extend ActiveSupport::Concern

  def wap_mbf_encrypt data, iv = ""
    iv = Digest::MD5.digest(iv)
    padding = 16 - data.length % 16
    data += padding.chr * padding
    cipher  = OpenSSL::Cipher::Cipher.new("aes-128-ecb")
    cipher.encrypt
    cipher.key = Settings.wap_mbf_key
    cipher.iv = iv
    encrypted = Base64.encode64(cipher.update(data)).gsub("\n",'')
  end

  def wap_mbf_decrypt data, iv = ""
    data = Base64.decode64(data)
    cipher = OpenSSL::Cipher::Cipher.new("aes-128-ecb")
    cipher.decrypt
    cipher.key = Settings.wap_mbf_key
    decrypted = cipher.update(data) + cipher.final
  end

end