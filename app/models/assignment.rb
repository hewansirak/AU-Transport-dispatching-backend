class Assignment < ApplicationRecord
  belongs_to :transport_request
  belongs_to :driver
  belongs_to :vehicle
  belongs_to :dispatcher, class_name: "User", foreign_key: :dispatcher_id

  validates :transport_request_id, :driver_id, :vehicle_id, :dispatcher_id, presence: true
end