require 'jwt'

class Auth
  ALGORITHM = 'HS256'.freeze

  def issue(payload)
    JWT.encode(payload, Rails.application.secrets.secret_key_base, ALGORITHM)
  end

  def decode(token)
    JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: ALGORITHM).first
  end
end
