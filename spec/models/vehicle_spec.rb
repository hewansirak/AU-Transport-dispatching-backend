require "rails_helper"

RSpec.describe Vehicle, type: :model do
  describe "associations" do
    it { should have_many(:assignments).dependent(:restrict_with_error) }
  end

  describe "validations" do
    subject { build(:vehicle) }
    it { should validate_presence_of(:plate_number) }
    it { should validate_uniqueness_of(:plate_number) }
    it { should validate_presence_of(:make) }
    it { should validate_presence_of(:model) }
  end

  describe "enums" do
    it {
      should define_enum_for(:vehicle_type)
        .with_values(sedan: 0, van: 1, pickup: 2, bus: 3, suv: 4)
    }
    it {
      should define_enum_for(:status)
        .with_values(available: 0, in_use: 1, maintenance: 2)
    }
  end
end