require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "associations" do
    it { should belong_to(:transport_request) }
    it { should belong_to(:recipient).class_name("User") }
  end

  describe "enums" do
    it { should define_enum_for(:channel).with_values(email: 0, sms: 1) }
    it {
      should define_enum_for(:notification_type).with_values(
        approval_notice: 0, rejection_notice: 1, assignment_notice: 2,
        trip_update: 3, reminder: 4
      )
    }
    it { should define_enum_for(:status).with_values(pending: 0, sent: 1, failed: 2) }
  end
end