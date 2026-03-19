class TransportMailer < ApplicationMailer

  # Sent to requester's department when supervisor approves
  def approval_notice(transport_request_id)
    @request = TransportRequest.includes(:requester, :department, :reviewed_by)
                               .find(transport_request_id)
    @requester   = @request.requester
    @reviewer    = @request.reviewed_by
    @department  = @request.department

    mail(
      to:      @requester.email,
      subject: "[AU Transport] Your request has been approved — Ref ##{@request.id}"
    )
  end

  # Sent to requester when request is rejected
  def rejection_notice(transport_request_id)
    @request    = TransportRequest.includes(:requester, :reviewed_by)
                                  .find(transport_request_id)
    @requester  = @request.requester
    @reviewer   = @request.reviewed_by

    mail(
      to:      @requester.email,
      subject: "[AU Transport] Your request was not approved — Ref ##{@request.id}"
    )
  end

  # Sent to department + driver + dispatcher supervisor on assignment
  def assignment_notice_to_department(transport_request_id)
    @request    = TransportRequest.includes(:requester, :department,
                                            assignment: [:driver, :vehicle, :dispatcher])
                                  .find(transport_request_id)
    @requester  = @request.requester
    @assignment = @request.assignment
    @driver     = @assignment.driver
    @vehicle    = @assignment.vehicle
    @dispatcher = @assignment.dispatcher

    mail(
      to:      @requester.email,
      subject: "[AU Transport] Driver & vehicle assigned — Ref ##{@request.id}"
    )
  end

  def assignment_notice_to_driver(transport_request_id)
    @request    = TransportRequest.includes(:requester, :department,
                                            assignment: [:driver, :vehicle, :dispatcher])
                                  .find(transport_request_id)
    @assignment = @request.assignment
    @driver     = @assignment.driver
    @vehicle    = @assignment.vehicle

    mail(
      to:      @driver.user.email,
      subject: "[AU Transport] New trip assignment — Ref ##{@request.id}"
    )
  end

  def assignment_notice_to_supervisor(transport_request_id, supervisor_id)
    @request    = TransportRequest.includes(:requester, :department,
                                            assignment: [:driver, :vehicle, :dispatcher])
                                  .find(transport_request_id)
    @supervisor = User.find(supervisor_id)
    @assignment = @request.assignment
    @driver     = @assignment.driver
    @vehicle    = @assignment.vehicle

    mail(
      to:      @supervisor.email,
      subject: "[AU Transport] Assignment monitoring — Ref ##{@request.id}"
    )
  end

  # Sent to department when driver updates trip status
  def trip_status_notice(transport_request_id, trip_status_update_id)
    @request = TransportRequest.includes(:requester,
                                         assignment: [:driver, :vehicle])
                               .find(transport_request_id)
    @update  = TripStatusUpdate.find(trip_status_update_id)
    @driver  = @update.driver
    @requester = @request.requester

    mail(
      to:      @requester.email,
      subject: "[AU Transport] Trip update: #{@update.status.humanize} — Ref ##{@request.id}"
    )
  end
end