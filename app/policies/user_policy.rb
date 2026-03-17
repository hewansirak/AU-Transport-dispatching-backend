class UserPolicy < ApplicationPolicy
  def index?   = user.admin? || user.dispatcher_supervisor?
  def show?    = user.admin? || user.id == record.id
  def create?  = user.admin?
  def update?  = user.admin? || user.id == record.id
  def destroy? = user.admin?

  def requests?
    user.admin? || user.id == record.id ||
      user.supervisor? || user.director?
  end
end