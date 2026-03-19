module Api
  module V1
    class TransportRequestsController < BaseController
      before_action :set_request, only: [:show, :update, :destroy, :approve, :reject]

      def index
        requests = policy_scope(
          TransportRequest
            .includes(:requester, :department, :reviewed_by, :assigned_by, :assignment)
            .order(created_at: :desc)
        )
        requests = apply_filters(requests)
        requests = requests.page(params[:page]).per(params[:per_page] || 20)

        render json: TransportRequestSerializer.new(
          requests,
          { include: [:requester, :department, :reviewed_by, :assigned_by] }
        ).serializable_hash
      end

      def show
        authorize @transport_request
        render json: TransportRequestSerializer.new(
          @transport_request,
          { include: [:requester, :department, :reviewed_by, :assigned_by, :assignment, :trip_status_updates] }
        ).serializable_hash
      end

      def create
        transport_request = TransportRequest.new(transport_request_params)
        transport_request.requester    = current_user
        transport_request.department   = current_user.department
        transport_request.status       = :pending

        authorize transport_request

        if transport_request.save
          render json: TransportRequestSerializer.new(transport_request).serializable_hash,
                 status: :created
        else
          render json: { errors: transport_request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @transport_request
        if @transport_request.update(transport_request_params)
          render json: TransportRequestSerializer.new(@transport_request).serializable_hash
        else
          render json: { errors: @transport_request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @transport_request
        @transport_request.update!(status: :cancelled)
        render json: { message: "Request cancelled" }
      end

      # POST /api/v1/transport_requests/:id/approve
      def approve
        authorize @transport_request

        @transport_request.assign_attributes(
          status:      :approved,
          reviewed_by: current_user,
          reviewed_at: Time.current
        )

        if @transport_request.save
          ApprovalNotificationJob.perform_later(@transport_request.id)
          render json: TransportRequestSerializer.new(@transport_request).serializable_hash
        else
          render json: { errors: @transport_request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/transport_requests/:id/reject
      def reject
        authorize @transport_request

        reason = params.dig(:transport_request, :rejection_reason)
        if reason.blank?
          return render json: { error: "rejection_reason is required" }, status: :unprocessable_entity
        end

        @transport_request.assign_attributes(
          status:           :rejected,
          reviewed_by:      current_user,
          reviewed_at:      Time.current,
          rejection_reason: reason
        )

        if @transport_request.save
          RejectionNotificationJob.perform_later(@transport_request.id) 
          render json: TransportRequestSerializer.new(@transport_request).serializable_hash
        else
          render json: { errors: @transport_request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_request
        @transport_request = TransportRequest.find(params[:id])
      end

      def transport_request_params
        params.require(:transport_request).permit(
          :originator_office,
          :telephone_extension,
          :required_date,
          :required_from_time,
          :required_to_time,
          :working_hours,
          :destination,
          :purpose,
          :service_type,
          :passenger_count
        )
      end

      def apply_filters(scope)
        scope = scope.where(status: params[:status])           if params[:status].present?
        scope = scope.where(department_id: params[:department_id]) if params[:department_id].present?
        scope = scope.where(service_type: params[:service_type])   if params[:service_type].present?
        scope = scope.where("required_date >= ?", params[:from_date]) if params[:from_date].present?
        scope = scope.where("required_date <= ?", params[:to_date])   if params[:to_date].present?
        scope
      end
    end
  end
end