class TransportRequestSerializer
  include JSONAPI::Serializer

  attributes :id,
             :originator_office,
             :telephone_extension,
             :required_date,
             :required_from_time,
             :required_to_time,
             :working_hours,
             :destination,
             :purpose,
             :service_type,
             :passenger_count,
             :status,
             :rejection_reason,
             :reviewed_at,
             :assigned_at,
             :created_at

  belongs_to :requester,   serializer: UserSerializer
  belongs_to :department
  belongs_to :reviewed_by, serializer: UserSerializer, record_type: :user
  belongs_to :assigned_by, serializer: UserSerializer, record_type: :user

  has_one  :assignment
  has_many :trip_status_updates
end