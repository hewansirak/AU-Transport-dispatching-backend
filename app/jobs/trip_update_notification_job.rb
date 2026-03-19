class TripUpdateNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(transport_request_id, trip_status_update_id)
    request = TransportRequest.find(transport_request_id)

    TransportMailer.trip_status_notice(
      transport_request_id,
      trip_status_update_id
    ).deliver_now

    Notification.create!(
      transport_request: request,
      recipient:         request.requester,
      channel:           :email,
      notification_type: :trip_update,
      status:            :sent,
      sent_at:           Time.current
    )
  rescue => e
    Rails.logger.error "TripUpdateNotificationJob failed: #{e.message}"
    raise
  end
end