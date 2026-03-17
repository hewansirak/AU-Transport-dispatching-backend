require "rails_helper"

RSpec.describe Department, type: :model do
  describe "associations" do
    it { should have_many(:users).dependent(:nullify) }
    it { should have_many(:transport_requests).dependent(:restrict_with_error) }
  end

  describe "validations" do
    subject { build(:department) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code).case_insensitive }
  end

  describe "enum" do
    it "defines the correct department names" do
      expect(Department.names.keys).to include(
        "hr", "mis", "finance", "procurement", "legal",
        "communications", "administration", "peace_security",
        "infrastructure", "social_affairs", "executive_office"
      )
    end
  end
end