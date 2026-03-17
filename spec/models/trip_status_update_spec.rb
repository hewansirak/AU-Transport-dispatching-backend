require "rails_helper"

RSpec.describe TripStatusUpdate, type: :model do
  describe "associations" do
    it { should belong_to(:transport_request) }
    it { should belong_to(:driver) }
  end

  describe "validations" do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:reported_at) }
  end

  describe "enums" do
    it {
      should define_enum_for(:status)
        .with_values(started: 0, en_route: 1, completed: 2)
    }
  end
end