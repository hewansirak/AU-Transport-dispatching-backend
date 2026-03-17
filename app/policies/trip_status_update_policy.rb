class TripStatusUpdatePolicy < ApplicationPolicy
  def index?  = true
  def create?
    # only the assigned driver for this request
    user.driver? &&
      record.transport_request.assignment&.driver&.user_id == user.id
  end
end