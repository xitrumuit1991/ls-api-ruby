module Api::V1::Wap extend ActiveSupport::Concern

  def encrypt data, iv = ""
    iv = Digest::MD5.digest(iv)
    padding = 16 - data.length % 16
    data += padding.chr * padding
    cipher  = OpenSSL::Cipher::Cipher.new("aes-128-ecb")
    cipher.encrypt
    cipher.key = "SincRqw0FvjUzsMT"
    cipher.iv = iv
    encrypted = cipher.update(data)
  end

  def decrypt data, iv = ""
    cipher = OpenSSL::Cipher::Cipher.new("aes-128-ecb")
    cipher.decrypt
    cipher.key = "SincRqw0FvjUzsMT"
    decrypted = cipher.update(data) + cipher.final
  end

end