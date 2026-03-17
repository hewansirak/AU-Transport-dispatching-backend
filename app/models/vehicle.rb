class Vehicle < ApplicationRecord
  enum :vehicle_type, {
    sedan:   0,
    van:     1,
    pickup:  2,
    bus:     3,
    suv:     4
  }

  enum :status, {
    available:   0,
    in_use:      1,
    maintenance: 2
  }

  has_many :assignments, dependent: :restrict_with_error

  validates :plate_number, presence: true, uniqueness: true
  validates :make, :model, presence: true
  validates :vehicle_type, :status, presence: true
end