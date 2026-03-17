class DepartmentPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true
  def create? = user.admin?
  def update? = user.admin?
end