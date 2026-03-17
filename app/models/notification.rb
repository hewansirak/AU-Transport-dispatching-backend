class Notification < ApplicationRecord
  enum :channel, {
    email: 0,
    sms:   1
  }

  enum :notification_type, {
    approval_notice:   0,
    rejection_notice:  1,
    assignment_notice: 2,
    trip_update:       3,
    reminder:          4
  }

  enum :status, {
    pending: 0,
    sent:    1,
    failed:  2
  }

  belongs_to :transport_request
  belongs_to :recipient, class_name: "User", foreign_key: :recipient_id

  validates :channel, :notification_type, :status, presence: true
end