class DepartmentSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :code
end