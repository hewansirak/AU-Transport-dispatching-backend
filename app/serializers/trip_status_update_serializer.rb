class TripStatusUpdateSerializer
  include JSONAPI::Serializer

  attributes :id,
             :status,
             :note,
             :location_note,
             :reported_at,
             :created_at

  belongs_to :transport_request
  belongs_to :driver
end