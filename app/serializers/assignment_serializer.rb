class AssignmentSerializer
  include JSONAPI::Serializer

  attributes :id, :notes, :created_at

  belongs_to :transport_request
  belongs_to :driver
  belongs_to :vehicle
  belongs_to :dispatcher, serializer: UserSerializer, record_type: :user
end