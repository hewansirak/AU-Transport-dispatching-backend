FactoryBot.define do
  factory :user do
    first_name            { Faker::Name.first_name }
    last_name             { Faker::Name.last_name }
    sequence(:email)      { |n| "user#{n}@au.int" }
    password              { "Password1!" }
    telephone_extension   { Faker::Number.number(digits: 4).to_s }
    role                  { :requester }
    active                { true }
    association           :department

    trait :requester do
      role { :requester }
    end

    trait :supervisor do
      role { :supervisor }
    end

    trait :director do
      role { :director }
    end

    trait :dispatcher do
      role { :dispatcher }
    end

    trait :dispatcher_supervisor do
      role { :dispatcher_supervisor }
    end

    trait :driver do
      role { :driver }
    end

    trait :admin do
      role { :admin }
    end

    trait :inactive do
      active { false }
    end
  end
end