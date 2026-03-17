require "rails_helper"

RSpec.describe Driver, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:assignments).dependent(:restrict_with_error) }
    it { should have_many(:trip_status_updates).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:driver) }
    it { should validate_presence_of(:license_number) }
    it { should validate_uniqueness_of(:license_number) }
    it { should validate_presence_of(:phone_number) }
  end

  describe "enums" do
    it {
      should define_enum_for(:status)
        .with_values(available: 0, on_trip: 1, off_duty: 2)
    }
  end

  describe "delegation" do
    let(:user)   { create(:user, :driver, first_name: "Tesfaye", last_name: "Girma") }
    let(:driver) { create(:driver, user: user) }

    it "delegates full_name to user" do
      expect(driver.full_name).to eq("Tesfaye Girma")
    end

    it "delegates email to user" do
      expect(driver.email).to eq(user.email)
    end
  end
end