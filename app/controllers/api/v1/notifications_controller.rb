module Api
  module V1
    class NotificationsController < BaseController
      before_action :set_notification, only: [:show, :mark_read]

      def index
        authorize Notification
        notifications = current_user.notifications
                                    .includes(:transport_request)
                                    .order(created_at: :desc)
        render json: NotificationSerializer.new(notifications).serializable_hash
      end

      def show
        authorize @notification
        render json: NotificationSerializer.new(@notification).serializable_hash
      end

      def mark_read
        authorize @notification
        @notification.update!(status: :sent, sent_at: Time.current)
        render json: NotificationSerializer.new(@notification).serializable_hash
      end

      private

      def set_notification
        @notification = Notification.find(params[:id])
      end
    end
  end
end