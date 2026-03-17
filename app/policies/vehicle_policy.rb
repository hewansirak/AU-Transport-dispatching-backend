class VehiclePolicy < ApplicationPolicy
  def index?    = true
  def show?     = true
  def available? = user.can_dispatch? || user.admin?
  def create?   = user.admin?
  def update?   = user.admin? || user.can_dispatch?
  def destroy?  = user.admin?
end