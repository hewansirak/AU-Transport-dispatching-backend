FactoryBot.define do
  factory :transport_request do
    association :requester, factory: :user
    association :department
    originator_office   { "Office of the #{Faker::Job.title}" }
    telephone_extension { Faker::Number.number(digits: 4).to_s }
    required_date       { 3.days.from_now.to_date }
    required_from_time  { "09:00" }
    required_to_time    { "11:00" }
    working_hours       { true }
    destination         { Faker::Address.city }
    purpose             { Faker::Lorem.sentence(word_count: 8) }
    service_type        { :passenger }
    passenger_count     { 2 }
    status              { :pending }

    trait :pickup do
      service_type    { :pickup }
      passenger_count { nil }
    end

    trait :pending      do status { :pending }      end
    trait :under_review do status { :under_review } end
    trait :approved     do status { :approved }     end
    trait :rejected     do
      status           { :rejected }
      rejection_reason { "Insufficient justification" }
    end
    trait :assigned    do status { :assigned }    end
    trait :in_progress do status { :in_progress } end
    trait :completed   do status { :completed }   end
    trait :cancelled   do status { :cancelled }   end

    trait :with_reviewer do
      association :reviewed_by, factory: [:user, :supervisor]
      reviewed_at { Time.current }
    end
  end
end