class ApprovalNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(transport_request_id)
    request = TransportRequest.find(transport_request_id)

    TransportMailer.approval_notice(transport_request_id).deliver_now

    Notification.create!(
      transport_request_id: transport_request_id,
      recipient:            request.requester,
      channel:              :email,
      notification_type:    :approval_notice,
      status:               :sent,
      sent_at:              Time.current
    )
  rescue => e
    Notification.create!(
      transport_request_id: transport_request_id,
      recipient:            TransportRequest.find(transport_request_id).requester,
      channel:              :email,
      notification_type:    :approval_notice,
      status:               :failed,
      metadata:             { error: e.message }
    )
    raise # re-raise so Sidekiq retries the job
  end
end