class AssignmentPolicy < ApplicationPolicy
  def show?   = user.can_dispatch? || user.dispatcher_supervisor? || user.admin? ||
                record.transport_request.requester_id == user.id
  def create? = user.can_dispatch? || user.admin?
  def update? = user.can_dispatch? || user.admin?
end