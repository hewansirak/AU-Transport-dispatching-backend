module AuthHelpers
  def auth_headers_for(user)
    token = JsonWebToken.encode({ user_id: user.id, role: user.role })
    { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end