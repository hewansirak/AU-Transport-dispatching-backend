require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should belong_to(:department).optional }
    it { should have_one(:driver_profile).class_name("Driver") }
    it { should have_many(:transport_requests).with_foreign_key(:requester_id) }
    it { should have_many(:notifications).with_foreign_key(:recipient_id) }
  end

  describe "validations" do
    subject { build(:user) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:role) }
  end

  describe "enums" do
    it {
      should define_enum_for(:role).with_values(
        requester: 0, supervisor: 1, director: 2, dispatcher: 3,
        dispatcher_supervisor: 4, driver: 5, admin: 6
      )
    }
  end

  describe "#full_name" do
    it "returns first and last name joined" do
      user = build(:user, first_name: "Kwame", last_name: "Asante")
      expect(user.full_name).to eq("Kwame Asante")
    end
  end

  describe "#can_review?" do
    it "returns true for supervisor" do
      expect(build(:user, :supervisor).can_review?).to be true
    end

    it "returns true for director" do
      expect(build(:user, :director).can_review?).to be true
    end

    it "returns true for admin" do
      expect(build(:user, :admin).can_review?).to be true
    end

    it "returns false for requester" do
      expect(build(:user, :requester).can_review?).to be false
    end

    it "returns false for driver" do
      expect(build(:user, :driver).can_review?).to be false
    end
  end

  describe "#can_dispatch?" do
    it "returns true for dispatcher" do
      expect(build(:user, :dispatcher).can_dispatch?).to be true
    end

    it "returns true for admin" do
      expect(build(:user, :admin).can_dispatch?).to be true
    end

    it "returns false for requester" do
      expect(build(:user, :requester).can_dispatch?).to be false
    end
  end

  describe "email normalisation" do
    it "downcases email before save" do
      user = create(:user, email: "TEST@AU.INT")
      expect(user.reload.email).to eq("test@au.int")
    end
  end
end