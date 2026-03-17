class VehicleSerializer
  include JSONAPI::Serializer

  attributes :id,
             :plate_number,
             :make,
             :model,
             :year,
             :vehicle_type,
             :capacity,
             :status,
             :notes
end