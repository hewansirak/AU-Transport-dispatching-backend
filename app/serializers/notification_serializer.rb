class NotificationSerializer
  include JSONAPI::Serializer

  attributes :id,
             :channel,
             :notification_type,
             :status,
             :sent_at,
             :metadata,
             :created_at

  belongs_to :transport_request
  belongs_to :recipient, serializer: UserSerializer, record_type: :user
end