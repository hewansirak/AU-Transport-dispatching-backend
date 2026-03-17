class ApplicationController < ActionController::API
  include ExceptionHandler
  include Pundit::Authorization

  before_action :authenticate_request!

  private

  def authenticate_request!
    raise ExceptionHandler::MissingToken, "Missing authorization token" unless auth_header

    token   = auth_header.split(" ").last
    decoded = JsonWebToken.decode(token)
    @current_user = User.find(decoded[:user_id])

    raise ExceptionHandler::AuthenticationError, "User not found" unless @current_user
    raise ExceptionHandler::AuthenticationError, "Account is inactive" unless @current_user.active?
  end

  def auth_header
    request.headers["Authorization"]
  end

  def current_user
    @current_user
  end

  # Pundit helper — override in specific controllers if scope differs
  def pundit_user
    current_user
  end
end