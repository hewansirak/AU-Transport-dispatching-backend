class AssignmentNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(transport_request_id)
    request            = TransportRequest.includes(assignment: [:driver, :vehicle, :dispatcher])
                                         .find(transport_request_id)
    assignment         = request.assignment
    dispatcher_supervisor = User.find_by(role: :dispatcher_supervisor)

    # 1. Notify the requesting department
    TransportMailer.assignment_notice_to_department(transport_request_id).deliver_now
    Notification.create!(
      transport_request: request,
      recipient:         request.requester,
      channel:           :email,
      notification_type: :assignment_notice,
      status:            :sent,
      sent_at:           Time.current
    )

    # 2. Notify the driver
    TransportMailer.assignment_notice_to_driver(transport_request_id).deliver_now
    Notification.create!(
      transport_request: request,
      recipient:         assignment.driver.user,
      channel:           :email,
      notification_type: :assignment_notice,
      status:            :sent,
      sent_at:           Time.current
    )

    # 3. Notify dispatcher supervisor for monitoring
    if dispatcher_supervisor
      TransportMailer.assignment_notice_to_supervisor(
        transport_request_id,
        dispatcher_supervisor.id
      ).deliver_now

      Notification.create!(
        transport_request: request,
        recipient:         dispatcher_supervisor,
        channel:           :email,
        notification_type: :assignment_notice,
        status:            :sent,
        sent_at:           Time.current
      )
    end
  rescue => e
    Rails.logger.error "AssignmentNotificationJob failed for request #{transport_request_id}: #{e.message}"
    raise
  end
end