class DriverSerializer
  include JSONAPI::Serializer

  attributes :id,
             :license_number,
             :license_expiry,
             :phone_number,
             :status,
             :notes

  belongs_to :user

  attribute :full_name do |driver|
    driver.user.full_name
  end

  attribute :email do |driver|
    driver.user.email
  end
end