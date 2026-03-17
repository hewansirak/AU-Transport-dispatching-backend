module Api
  module V1
    class TripStatusUpdatesController < BaseController
      before_action :set_transport_request

      def index
        authorize TripStatusUpdate
        updates = @transport_request.trip_status_updates
                                    .includes(:driver)
                                    .order(reported_at: :asc)
        render json: TripStatusUpdateSerializer.new(updates).serializable_hash
      end

      def create
        update = @transport_request.trip_status_updates.build(trip_status_params)
        update.driver      = current_user.driver_profile
        update.reported_at = Time.current

        authorize update

        ActiveRecord::Base.transaction do
          update.save!

          # mirror the status on the parent request
          if update.completed?
            @transport_request.update!(status: :completed)
            update.driver.update!(status: :available)
            @transport_request.assignment&.vehicle&.update!(status: :available)
          elsif update.started? || update.en_route?
            @transport_request.update!(status: :in_progress)
          end
          # TODO: step 4 — trigger TripUpdateNotificationJob here
        end

        render json: TripStatusUpdateSerializer.new(update).serializable_hash,
               status: :created

      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      private

      def set_transport_request
        @transport_request = TransportRequest.find(params[:transport_request_id])
      end

      def trip_status_params
        params.require(:trip_status_update).permit(:status, :note, :location_note)
      end
    end
  end
end