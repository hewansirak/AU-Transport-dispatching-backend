class JsonWebToken
  SECRET = ENV.fetch("JWT_SECRET")
  ALGORITHM = "HS256"
  ACCESS_EXPIRY  = 24.hours.from_now
  REFRESH_EXPIRY = 7.days.from_now

  def self.encode(payload, exp = ACCESS_EXPIRY)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET, true, algorithm: ALGORITHM)
    HashWithIndifferentAccess.new(decoded.first)
  rescue JWT::ExpiredSignature
    raise ExceptionHandler::ExpiredToken
  rescue JWT::DecodeError
    raise ExceptionHandler::InvalidToken
  end
end