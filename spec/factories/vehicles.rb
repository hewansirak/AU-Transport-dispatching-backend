FactoryBot.define do
  factory :vehicle do
    sequence(:plate_number) { |n| "AU-#{n.to_s.rjust(3, "0")}-ET" }
    make         { Faker::Vehicle.make }
    model        { Faker::Vehicle.model }
    year         { Faker::Vehicle.year }
    vehicle_type { :sedan }
    capacity     { 5 }
    status       { :available }

    trait :van     do vehicle_type { :van };     capacity { 14 } end
    trait :pickup  do vehicle_type { :pickup };  capacity { 3 }  end
    trait :bus     do vehicle_type { :bus };     capacity { 30 } end
    trait :in_use      do status { :in_use }      end
    trait :maintenance do status { :maintenance } end
  end
end