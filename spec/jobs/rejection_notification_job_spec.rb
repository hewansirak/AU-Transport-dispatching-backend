require "rails_helper"

RSpec.describe RejectionNotificationJob, type: :job do
  let(:department) { create(:department) }
  let(:requester)  { create(:user, :requester, department: department) }
  let(:supervisor) { create(:user, :supervisor, department: department) }
  let(:request) do
    create(:transport_request, :rejected,
           requester:        requester,
           department:       department,
           reviewed_by:      supervisor,
           reviewed_at:      Time.current,
           rejection_reason: "Not justified")
  end

  before { ActionMailer::Base.deliveries.clear }

  it "sends one email" do
    described_class.perform_now(request.id)
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end

  it "sends to the requester" do
    described_class.perform_now(request.id)
    expect(ActionMailer::Base.deliveries.last.to).to include(requester.email)
  end

  it "creates a sent notification record" do
    expect {
      described_class.perform_now(request.id)
    }.to change(Notification, :count).by(1)

    expect(Notification.last.notification_type).to eq("rejection_notice")
  end
end