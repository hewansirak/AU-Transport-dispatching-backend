require "rails_helper"

RSpec.describe AssignmentNotificationJob, type: :job do
  let(:department)       { create(:department) }
  let(:requester)        { create(:user, :requester,             department: department) }
  let(:dispatcher)       { create(:user, :dispatcher,            department: department) }
  let(:disp_supervisor)  { create(:user, :dispatcher_supervisor, department: department) }
  let(:driver_user)      { create(:user, :driver,                department: department) }
  let(:driver)           { create(:driver, user: driver_user) }
  let(:vehicle)          { create(:vehicle) }
  let(:transport_request) do
    create(:transport_request, :assigned,
           requester:   requester,
           department:  department)
  end

  before do
    create(:assignment,
           transport_request: transport_request,
           driver:            driver,
           vehicle:           vehicle,
           dispatcher:        dispatcher)
    disp_supervisor
    ActionMailer::Base.deliveries.clear
  end

  it "sends three emails — department, driver, supervisor" do
    described_class.perform_now(transport_request.id)
    expect(ActionMailer::Base.deliveries.count).to eq(3)
  end

  it "sends to requester, driver, and dispatcher supervisor" do
    described_class.perform_now(transport_request.id)
    recipients = ActionMailer::Base.deliveries.flat_map(&:to)
    expect(recipients).to include(requester.email)
    expect(recipients).to include(driver_user.email)
    expect(recipients).to include(disp_supervisor.email)
  end

  it "creates three notification records" do
    expect {
      described_class.perform_now(transport_request.id)
    }.to change(Notification, :count).by(3)
  end

  it "all notifications have status sent" do
    described_class.perform_now(transport_request.id)
    expect(Notification.last(3).map(&:status).uniq).to eq(["sent"])
  end

  it "skips supervisor email gracefully if no dispatcher_supervisor exists" do
    disp_supervisor.update!(role: :requester)
    expect {
      described_class.perform_now(transport_request.id)
    }.not_to raise_error
    expect(ActionMailer::Base.deliveries.count).to eq(2)
  end
end