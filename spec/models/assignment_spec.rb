require "rails_helper"

RSpec.describe Assignment, type: :model do
  describe "associations" do
    it { should belong_to(:transport_request) }
    it { should belong_to(:driver) }
    it { should belong_to(:vehicle) }
    it { should belong_to(:dispatcher).class_name("User") }
  end

  describe "validations" do
    it { should validate_presence_of(:transport_request_id) }
    it { should validate_presence_of(:driver_id) }
    it { should validate_presence_of(:vehicle_id) }
    it { should validate_presence_of(:dispatcher_id) }
  end
end