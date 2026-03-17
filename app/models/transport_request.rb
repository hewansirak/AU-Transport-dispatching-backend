class TransportRequest < ApplicationRecord
  enum :status, {
    pending:      0,
    under_review: 1,
    approved:     2,
    rejected:     3,
    assigned:     4,
    in_progress:  5,
    completed:    6,
    cancelled:    7
  }

  enum :service_type, {
    passenger: 0,
    pickup:    1
  }

  belongs_to :requester,   class_name: "User", foreign_key: :requester_id
  belongs_to :department
  belongs_to :reviewed_by, class_name: "User", foreign_key: :reviewed_by_id, optional: true
  belongs_to :assigned_by, class_name: "User", foreign_key: :assigned_by_id, optional: true

  has_one  :assignment,          dependent: :destroy
  has_many :trip_status_updates, dependent: :destroy
  has_many :notifications,       dependent: :destroy

  validates :originator_office,  presence: true
  validates :destination,        presence: true
  validates :purpose,            presence: true
  validates :required_date,      presence: true
  validates :required_from_time, presence: true
  validates :required_to_time,   presence: true
  validates :service_type,       presence: true
  validates :status,             presence: true

  validates :passenger_count,
            presence: true,
            numericality: { greater_than: 0 },
            if: :passenger?

  validate :required_to_time_after_from_time

  private

  def required_to_time_after_from_time
    return unless required_from_time && required_to_time
    if required_to_time <= required_from_time
      errors.add(:required_to_time, "must be after the from time")
    end
  end
end