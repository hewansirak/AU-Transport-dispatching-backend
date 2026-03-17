class TransportRequestPolicy < ApplicationPolicy

  def index?  = true   # scope handles what each role actually sees
  def show?   = owner_or_reviewer_or_dispatcher?
  def create? = user.requester? || user.admin?

  def update?
    # requester can only edit their own pending request
    (record.requester_id == user.id && record.pending?) || user.admin?
  end

  def destroy?
    (record.requester_id == user.id && record.pending?) || user.admin?
  end

  def approve?
    (user.supervisor? || user.director? || user.admin?) &&
      record.pending? || record.under_review?
  end

  def reject?
    (user.supervisor? || user.director? || user.admin?) &&
      record.pending? || record.under_review?
  end

  class Scope < Scope
    def resolve
      case user.role.to_sym
      when :requester
        scope.where(requester_id: user.id)
      when :supervisor, :director
        scope.where(department_id: user.department_id)
      when :dispatcher, :dispatcher_supervisor, :admin
        scope.all
      when :driver
        # drivers see requests assigned to them
        scope.joins(:assignment).where(assignments: { driver_id: user.driver_profile&.id })
      else
        scope.none
      end
    end
  end

  private

  def owner_or_reviewer_or_dispatcher?
    record.requester_id == user.id ||
      user.can_review? ||
      user.can_dispatch? ||
      user.dispatcher_supervisor? ||
      user.admin?
  end
end