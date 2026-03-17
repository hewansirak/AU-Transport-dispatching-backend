module ExceptionHandler
  extend ActiveSupport::Concern

  class AuthenticationError < StandardError; end
  class MissingToken        < StandardError; end
  class InvalidToken        < StandardError; end
  class ExpiredToken        < StandardError; end
  class UnauthorizedAction  < StandardError; end

  included do
    rescue_from ExceptionHandler::AuthenticationError, with: :unauthorized
    rescue_from ExceptionHandler::MissingToken,        with: :unauthorized
    rescue_from ExceptionHandler::InvalidToken,        with: :unprocessable
    rescue_from ExceptionHandler::ExpiredToken,        with: :token_expired
    rescue_from ExceptionHandler::UnauthorizedAction,  with: :forbidden
    rescue_from Pundit::NotAuthorizedError,             with: :forbidden
    rescue_from ActiveRecord::RecordNotFound,           with: :not_found
    rescue_from ActiveRecord::RecordInvalid,            with: :unprocessable
  end

  private

  def unauthorized(e)
    render json: { error: e.message || "Unauthorized" }, status: :unauthorized
  end

  def forbidden(e)
    render json: { error: e.message || "Forbidden" }, status: :forbidden
  end

  def not_found(e)
    render json: { error: e.message || "Resource not found" }, status: :not_found
  end

  def unprocessable(e)
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def token_expired(_e)
    render json: { error: "Token has expired, please log in again" }, status: :unauthorized
  end
end