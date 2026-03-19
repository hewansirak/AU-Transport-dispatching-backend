require "rails_helper"

RSpec.describe TripUpdateNotificationJob, type: :job do
  let(:department)  { create(:department) }
  let(:requester)   { create(:user, :requester,  department: department) }
  let(:dispatcher)  { create(:user, :dispatcher, department: department) }
  let(:driver_user) { create(:user, :driver,     department: department) }
  let(:driver)      { create(:driver, user: driver_user) }
  let(:vehicle)     { create(:vehicle) }
  let(:transport_request) do
    create(:transport_request, :assigned,
           requester:  requester,
           department: department)
  end
  let(:trip_update) do
    create(:trip_status_update, :started,
           transport_request: transport_request,
           driver:            driver,
           reported_at:       Time.current)
  end

  before do
    create(:assignment,
           transport_request: transport_request,
           driver:            driver,
           vehicle:           vehicle,
           dispatcher:        dispatcher)
    ActionMailer::Base.deliveries.clear
  end

  it "sends one email to the requester" do
    described_class.perform_now(transport_request.id, trip_update.id)
    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(ActionMailer::Base.deliveries.last.to).to include(requester.email)
  end

  it "creates a trip_update notification record" do
    expect {
      described_class.perform_now(transport_request.id, trip_update.id)
    }.to change(Notification, :count).by(1)

    expect(Notification.last.notification_type).to eq("trip_update")
  end
end