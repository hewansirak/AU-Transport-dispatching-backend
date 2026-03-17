require "rails_helper"

RSpec.describe TransportRequest, type: :model do
  describe "associations" do
    it { should belong_to(:requester).class_name("User") }
    it { should belong_to(:department) }
    it { should belong_to(:reviewed_by).class_name("User").optional }
    it { should belong_to(:assigned_by).class_name("User").optional }
    it { should have_one(:assignment).dependent(:destroy) }
    it { should have_many(:trip_status_updates).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:transport_request) }
    it { should validate_presence_of(:originator_office) }
    it { should validate_presence_of(:destination) }
    it { should validate_presence_of(:purpose) }
    it { should validate_presence_of(:required_date) }
    it { should validate_presence_of(:required_from_time) }
    it { should validate_presence_of(:required_to_time) }
  end

  describe "enums" do
    it {
      should define_enum_for(:status).with_values(
        pending: 0, under_review: 1, approved: 2, rejected: 3,
        assigned: 4, in_progress: 5, completed: 6, cancelled: 7
      )
    }
    it {
      should define_enum_for(:service_type)
        .with_values(passenger: 0, pickup: 1)
    }
  end

  describe "passenger_count validation" do
    it "requires passenger_count when service_type is passenger" do
      request = build(:transport_request, service_type: :passenger, passenger_count: nil)
      expect(request).not_to be_valid
      expect(request.errors[:passenger_count]).to be_present
    end

    it "does not require passenger_count for pickup" do
      request = build(:transport_request, :pickup)
      expect(request).to be_valid
    end

    it "requires passenger_count greater than 0" do
      request = build(:transport_request, service_type: :passenger, passenger_count: 0)
      expect(request).not_to be_valid
    end
  end

  describe "time validation" do
    it "is invalid when to_time is before from_time" do
      request = build(:transport_request,
                      required_from_time: "14:00",
                      required_to_time:   "09:00")
      expect(request).not_to be_valid
      expect(request.errors[:required_to_time]).to include("must be after the from time")
    end

    it "is invalid when to_time equals from_time" do
      request = build(:transport_request,
                      required_from_time: "09:00",
                      required_to_time:   "09:00")
      expect(request).not_to be_valid
    end

    it "is valid when to_time is after from_time" do
      request = build(:transport_request,
                      required_from_time: "09:00",
                      required_to_time:   "11:00")
      expect(request).to be_valid
    end
  end
end