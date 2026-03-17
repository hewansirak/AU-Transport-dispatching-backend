class TripStatusUpdate < ApplicationRecord
  enum :status, {
    started:   0,
    en_route:  1,
    completed: 2
  }

  belongs_to :transport_request
  belongs_to :driver

  validates :status, :reported_at, presence: true
end