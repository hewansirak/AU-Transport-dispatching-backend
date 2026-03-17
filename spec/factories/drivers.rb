FactoryBot.define do
  factory :driver do
    association :user, factory: [:user, :driver]
    sequence(:license_number) { |n| "ETH-DRV-#{n.to_s.rjust(3, "0")}" }
    license_expiry { 2.years.from_now }
    phone_number   { Faker::PhoneNumber.cell_phone }
    status         { :available }

    trait :on_trip  do status { :on_trip }  end
    trait :off_duty do status { :off_duty } end
  end
end