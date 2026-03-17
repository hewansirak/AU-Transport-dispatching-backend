class Driver < ApplicationRecord
  enum :status, {
    available: 0,
    on_trip:   1,
    off_duty:  2
  }

  belongs_to :user

  has_many :assignments,         dependent: :restrict_with_error
  has_many :trip_status_updates, dependent: :destroy

  validates :license_number, presence: true, uniqueness: true
  validates :phone_number,   presence: true
  validates :status,         presence: true

  delegate :full_name, :email, to: :user
end