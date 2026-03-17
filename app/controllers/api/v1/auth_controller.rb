module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_request!, only: [:login]

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: login_params[:email].downcase.strip)

        if user&.authenticate(login_params[:password])
          unless user.active?
            return render json: { error: "Account is deactivated. Contact your administrator." },
                          status: :forbidden
          end

          access_token  = JsonWebToken.encode({ user_id: user.id, role: user.role })
          refresh_token = JsonWebToken.encode(
            { user_id: user.id, type: "refresh" },
            JsonWebToken::REFRESH_EXPIRY
          )

          render json: {
            data: {
              access_token:  access_token,
              refresh_token: refresh_token,
              token_type:    "Bearer",
              expires_in:    24.hours.to_i,
              user:          user_payload(user)
            }
          }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        # If you add token blacklisting (Redis) later, invalidate here.
        # For now, the client simply discards the token.
        render json: { message: "Logged out successfully" }, status: :ok
      end

      # POST /api/v1/auth/refresh
      def refresh
        token   = request.headers["X-Refresh-Token"]
        decoded = JsonWebToken.decode(token)

        unless decoded[:type] == "refresh"
          return render json: { error: "Invalid refresh token" }, status: :unauthorized
        end

        user = User.find(decoded[:user_id])

        new_access = JsonWebToken.encode({ user_id: user.id, role: user.role })

        render json: {
          data: {
            access_token: new_access,
            token_type:   "Bearer",
            expires_in:   24.hours.to_i
          }
        }, status: :ok
      end

      # GET /api/v1/auth/me
      def me
        render json: { data: user_payload(current_user) }, status: :ok
      end

      private

      def login_params
        params.require(:auth).permit(:email, :password)
      end

      def user_payload(user)
        {
          id:                 user.id,
          first_name:         user.first_name,
          last_name:          user.last_name,
          email:              user.email,
          role:               user.role,
          department:         user.department&.name,
          telephone_extension: user.telephone_extension
        }
      end
    end
  end
end