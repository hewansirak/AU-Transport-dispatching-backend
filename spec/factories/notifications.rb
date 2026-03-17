FactoryBot.define do
  factory :notification do
    association :transport_request
    association :recipient, factory: :user
    channel           { :email }
    notification_type { :approval_notice }
    status            { :pending }
    sent_at           { nil }
    metadata          { {} }
  end
end