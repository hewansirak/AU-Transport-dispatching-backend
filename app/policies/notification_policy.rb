class NotificationPolicy < ApplicationPolicy
  def index?     = true   # scoped to own notifications
  def show?      = record.recipient_id == user.id || user.admin?
  def mark_read? = record.recipient_id == user.id
end