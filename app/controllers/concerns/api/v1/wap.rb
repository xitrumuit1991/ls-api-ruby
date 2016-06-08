module Api::V1::Wap extend ActiveSupport::Concern

  def encrypt data, iv = ""
    iv = Digest::MD5.digest(iv)
    padding = 16 - data.length % 16
    data += padding.chr * padding
    cipher  = OpenSSL::Cipher::Cipher.new("aes-128-ecb")
    cipher.encrypt
    cipher.key = Settings.wap_mbf_key
    cipher.iv = iv
    encrypted = cipher.update(data)
    encrypted_base64 = Base64.encode64(cipher.update(data)).gsub("\n",'')
    puts '==================='
    puts Settings.wap_mbf_key
    puts Settings.wap_mbf_key.length
    puts iv
    puts iv.length
    puts padding
    # puts padding.length
    puts data
    puts data.length
    puts encrypted
    puts encrypted.length
    puts encrypted_base64
    puts encrypted_base64.length
    puts '==================='
  end

  def decrypt data, iv = ""
    data = Base64.decode64(data)
    cipher = OpenSSL::Cipher::Cipher.new("aes-128-ecb")
    cipher.decrypt
    cipher.key = Settings.wap_mbf_key
    decrypted = cipher.update(data) + cipher.final
  end

end