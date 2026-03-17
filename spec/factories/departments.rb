FactoryBot.define do
  factory :department do
    sequence(:name) { |n| Department.names.keys[n % Department.names.size].to_s }
    sequence(:code) { |n| "DEPT#{n}" }
  end

  # named factories for convenience in other specs
  Department.names.each_key do |dept_name|
    factory :"#{dept_name}_department", parent: :department do
      name { dept_name.to_s }
      code { dept_name.to_s.upcase[0..3] }
    end
  end
end