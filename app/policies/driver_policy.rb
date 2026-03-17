class DriverPolicy < ApplicationPolicy
  def index?       = user.can_dispatch? || user.admin? || user.dispatcher_supervisor?
  def show?        = user.can_dispatch? || user.admin? || user.dispatcher_supervisor?
  def available?   = user.can_dispatch? || user.admin?
  def assignments? = user.can_dispatch? || user.admin? || user.dispatcher_supervisor?
  def create?      = user.admin?
  def update?      = user.admin?
  def destroy?     = user.admin?
end