module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [:show, :update, :destroy, :requests]

      def index
        authorize User
        users = User.includes(:department).order(:last_name)
        render json: UserSerializer.new(users, { include: [:department] }).serializable_hash
      end

      def show
        authorize @user
        render json: UserSerializer.new(@user, { include: [:department] }).serializable_hash
      end

      def create
        user = User.new(user_params)
        authorize user
        if user.save
          render json: UserSerializer.new(user).serializable_hash, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @user
        if @user.update(update_user_params)
          render json: UserSerializer.new(@user).serializable_hash
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @user
        @user.update!(active: false)   # soft delete — never hard delete users
        render json: { message: "User deactivated successfully" }
      end

      def requests
        authorize @user, :requests?
        transport_requests = policy_scope(
          TransportRequest.where(requester_id: @user.id).includes(:department, :requester)
        )
        render json: TransportRequestSerializer.new(transport_requests).serializable_hash
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(
          :first_name, :last_name, :email, :password,
          :role, :department_id, :telephone_extension, :active
        )
      end

      def update_user_params
        allowed = [:first_name, :last_name, :telephone_extension]
        allowed += [:role, :department_id, :active, :email] if current_user.admin?
        params.require(:user).permit(allowed)
      end
    end
  end
end