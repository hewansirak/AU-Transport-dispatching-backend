require "rails_helper"

RSpec.describe ApprovalNotificationJob, type: :job do
  let(:department) { create(:department) }
  let(:requester)  { create(:user, :requester, department: department) }
  let(:supervisor) { create(:user, :supervisor, department: department) }
  let(:request) do
    create(:transport_request, :approved,
           requester:   requester,
           department:  department,
           reviewed_by: supervisor,
           reviewed_at: Time.current)
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

    notification = Notification.last
    expect(notification.status).to        eq("sent")
    expect(notification.notification_type).to eq("approval_notice")
    expect(notification.recipient).to     eq(requester)
  end

  it "is queued on the notifications queue" do
    expect(described_class.new.queue_name).to eq("notifications")
  end
end