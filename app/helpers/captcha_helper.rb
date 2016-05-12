module CaptchaHelper
  def checkCaptcha(key)
    uri = URI('https://www.google.com/recaptcha/api/siteverify?secret=' + Settings.secret_key_captcha + '&response=' + key)
    return Net::HTTP.get(uri)
  end
end