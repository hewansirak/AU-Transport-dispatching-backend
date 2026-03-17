module Api
  module V1
    class VehiclesController < BaseController
      before_action :set_vehicle, only: [:show, :update, :destroy]

      def index
        authorize Vehicle
        vehicles = Vehicle.all.order(:plate_number)
        vehicles = vehicles.where(vehicle_type: params[:vehicle_type]) if params[:vehicle_type].present?
        vehicles = vehicles.where(status: params[:status])             if params[:status].present?
        render json: VehicleSerializer.new(vehicles).serializable_hash
      end

      def available
        authorize Vehicle, :available?
        vehicles = Vehicle.available.order(:plate_number)
        render json: VehicleSerializer.new(vehicles).serializable_hash
      end

      def show
        authorize @vehicle
        render json: VehicleSerializer.new(@vehicle).serializable_hash
      end

      def create
        vehicle = Vehicle.new(vehicle_params)
        authorize vehicle
        if vehicle.save
          render json: VehicleSerializer.new(vehicle).serializable_hash, status: :created
        else
          render json: { errors: vehicle.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @vehicle
        if @vehicle.update(vehicle_params)
          render json: VehicleSerializer.new(@vehicle).serializable_hash
        else
          render json: { errors: @vehicle.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @vehicle
        @vehicle.update!(status: :maintenance)  # never hard delete fleet assets
        render json: { message: "Vehicle marked as under maintenance" }
      end

      private

      def set_vehicle
        @vehicle = Vehicle.find(params[:id])
      end

      def vehicle_params
        params.require(:vehicle).permit(
          :plate_number, :make, :model, :year,
          :vehicle_type, :capacity, :status, :notes
        )
      end
    end
  end
end