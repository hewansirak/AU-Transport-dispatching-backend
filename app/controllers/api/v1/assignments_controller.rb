module Api
  module V1
    class AssignmentsController < BaseController
      before_action :set_transport_request
      before_action :set_assignment, only: [:show, :update]

      def show
        authorize @assignment
        render json: AssignmentSerializer.new(
          @assignment,
          { include: [:driver, :vehicle, :dispatcher] }
        ).serializable_hash
      end

      def create
        authorize Assignment

        # guard: request must be approved before it can be assigned
        unless @transport_request.approved?
          return render json: { error: "Request must be approved before assignment" },
                        status: :unprocessable_entity
        end

        # guard: no existing assignment
        if @transport_request.assignment.present?
          return render json: { error: "Request is already assigned. Use PATCH to reassign." },
                        status: :unprocessable_entity
        end

        assignment = Assignment.new(assignment_params)
        assignment.transport_request = @transport_request
        assignment.dispatcher        = current_user

        ActiveRecord::Base.transaction do
          assignment.save!
          @transport_request.update!(status: :assigned, assigned_by: current_user, assigned_at: Time.current)
          assignment.driver.update!(status: :on_trip)
          assignment.vehicle.update!(status: :in_use)
          # TODO: step 4 — trigger AssignmentNotificationJob here
        end
        
        AssignmentNotificationJob.perform_later(@transport_request.id)

        render json: AssignmentSerializer.new(
          assignment,
          { include: [:driver, :vehicle, :dispatcher] }
        ).serializable_hash, status: :created

      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      def update
        authorize @assignment

        ActiveRecord::Base.transaction do
          # Free the old driver and vehicle if they are being replaced
          if assignment_params[:driver_id] && assignment_params[:driver_id] != @assignment.driver_id.to_s
            @assignment.driver.update!(status: :available)
            Driver.find(assignment_params[:driver_id]).update!(status: :on_trip)
          end

          if assignment_params[:vehicle_id] && assignment_params[:vehicle_id] != @assignment.vehicle_id.to_s
            @assignment.vehicle.update!(status: :available)
            Vehicle.find(assignment_params[:vehicle_id]).update!(status: :in_use)
          end

          @assignment.update!(assignment_params)
        end

        render json: AssignmentSerializer.new(@assignment).serializable_hash

      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      private

      def set_transport_request
        @transport_request = TransportRequest.find(params[:transport_request_id])
      end

      def set_assignment
        @assignment = @transport_request.assignment
        raise ActiveRecord::RecordNotFound, "No assignment found for this request" unless @assignment
      end

      def assignment_params
        params.require(:assignment).permit(:driver_id, :vehicle_id, :notes)
      end
    end
  end
end