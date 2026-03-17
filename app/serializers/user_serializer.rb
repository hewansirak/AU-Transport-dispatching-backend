class UserSerializer
  include JSONAPI::Serializer

  attributes :id,
             :first_name,
             :last_name,
             :email,
             :role,
             :telephone_extension,
             :active

  belongs_to :department
end