module Api
  module V1
    class DriversController < BaseController
      before_action :set_driver, only: [:show, :update, :destroy, :assignments]

      def index
        authorize Driver
        drivers = Driver.includes(:user).order("users.last_name")
        drivers = drivers.where(status: params[:status]) if params[:status].present?
        render json: DriverSerializer.new(drivers, { include: [:user] }).serializable_hash
      end

      def available
        authorize Driver, :available?
        drivers = Driver.available.includes(:user).order("users.last_name")
        render json: DriverSerializer.new(drivers, { include: [:user] }).serializable_hash
      end

      def show
        authorize @driver
        render json: DriverSerializer.new(@driver, { include: [:user] }).serializable_hash
      end

      def assignments
        authorize @driver, :assignments?
        requests = TransportRequest
                     .joins(:assignment)
                     .where(assignments: { driver_id: @driver.id })
                     .includes(:requester, :department)
                     .order(created_at: :desc)
        render json: TransportRequestSerializer.new(
          requests,
          { include: [:requester, :department] }
        ).serializable_hash
      end

      def create
        authorize Driver
        user   = User.find(driver_params[:user_id])
        driver = Driver.new(driver_params)
        if driver.save
          render json: DriverSerializer.new(driver).serializable_hash, status: :created
        else
          render json: { errors: driver.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @driver
        if @driver.update(driver_update_params)
          render json: DriverSerializer.new(@driver).serializable_hash
        else
          render json: { errors: @driver.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @driver
        @driver.update!(status: :off_duty)
        render json: { message: "Driver set to off duty" }
      end

      private

      def set_driver
        @driver = Driver.find(params[:id])
      end

      def driver_params
        params.require(:driver).permit(
          :user_id, :license_number, :license_expiry,
          :phone_number, :status, :notes
        )
      end

      def driver_update_params
        params.require(:driver).permit(
          :license_number, :license_expiry,
          :phone_number, :status, :notes
        )
      end
    end
  end
end