FactoryBot.define do
  factory :trip_status_update do
    association :transport_request, factory: [:transport_request, :assigned]
    association :driver
    status      { :started }
    reported_at { Time.current }
    note        { nil }
    location_note { nil }

    trait :started   do status { :started }   end
    trait :en_route  do status { :en_route }  end
    trait :completed do status { :completed } end
  end
end