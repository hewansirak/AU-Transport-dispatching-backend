FactoryBot.define do
  factory :assignment do
    association :transport_request, factory: [:transport_request, :approved]
    association :driver
    association :vehicle
    association :dispatcher, factory: [:user, :dispatcher]
    notes { nil }
  end
end