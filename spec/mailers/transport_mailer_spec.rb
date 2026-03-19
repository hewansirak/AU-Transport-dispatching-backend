require "rails_helper"

RSpec.describe TransportMailer, type: :mailer do
  let(:department)  { create(:department) }
  let(:requester)   { create(:user, :requester,  department: department) }
  let(:supervisor)  { create(:user, :supervisor, department: department) }
  let(:dispatcher)  { create(:user, :dispatcher, department: department) }
  let(:driver_user) { create(:user, :driver,     department: department) }
  let(:driver)      { create(:driver, user: driver_user) }
  let(:vehicle)     { create(:vehicle) }

  let(:transport_request) do
    create(:transport_request, :approved,
           requester:    requester,
           department:   department,
           reviewed_by:  supervisor,
           reviewed_at:  Time.current,
           destination:  "Addis Ababa Airport",
           purpose:      "Pick up delegation")
  end

  let(:assignment) do
    create(:assignment,
           transport_request: transport_request,
           driver:            driver,
           vehicle:           vehicle,
           dispatcher:        dispatcher)
  end

  describe "#approval_notice" do
    let(:mail) { TransportMailer.approval_notice(transport_request.id) }

    it "sends to the requester" do
      expect(mail.to).to eq([requester.email])
    end

    it "has the correct subject" do
      expect(mail.subject).to include("approved")
      expect(mail.subject).to include("##{transport_request.id}")
    end

    it "includes the destination in the body" do
      expect(mail.body.to_s).to include("Addis Ababa Airport")
    end

    it "includes the reviewer's name" do
      expect(mail.body.to_s).to include(supervisor.full_name)
    end

    it "includes the AU header" do
      expect(mail.body.to_s).to include("African Union")
    end
  end

  describe "#rejection_notice" do
    let(:rejected_request) do
      create(:transport_request, :rejected,
             requester:        requester,
             department:       department,
             reviewed_by:      supervisor,
             reviewed_at:      Time.current,
             rejection_reason: "Budget constraints this quarter")
    end

    let(:mail) { TransportMailer.rejection_notice(rejected_request.id) }

    it "sends to the requester" do
      expect(mail.to).to eq([requester.email])
    end

    it "has the correct subject" do
      expect(mail.subject).to include("not approved")
      expect(mail.subject).to include("##{rejected_request.id}")
    end

    it "includes the rejection reason" do
      expect(mail.body.to_s).to include("Budget constraints this quarter")
    end

    it "includes the reviewer's name" do
      expect(mail.body.to_s).to include(supervisor.full_name)
    end
  end

  describe "#assignment_notice_to_department" do
    let(:mail) { TransportMailer.assignment_notice_to_department(transport_request.id) }

    before { assignment }

    it "sends to the requester" do
      expect(mail.to).to eq([requester.email])
    end

    it "has the correct subject" do
      expect(mail.subject).to include("assigned")
      expect(mail.subject).to include("##{transport_request.id}")
    end

    it "includes driver name and phone" do
      expect(mail.body.to_s).to include(driver.full_name)
      expect(mail.body.to_s).to include(driver.phone_number)
    end

    it "includes vehicle details" do
      expect(mail.body.to_s).to include(vehicle.plate_number)
      expect(mail.body.to_s).to include(vehicle.make)
    end

    it "includes dispatcher name" do
      expect(mail.body.to_s).to include(dispatcher.full_name)
    end
  end

  describe "#assignment_notice_to_driver" do
    let(:mail) { TransportMailer.assignment_notice_to_driver(transport_request.id) }

    before { assignment }

    it "sends to the driver's email" do
      expect(mail.to).to eq([driver_user.email])
    end

    it "has the correct subject" do
      expect(mail.subject).to include("assignment")
      expect(mail.subject).to include("##{transport_request.id}")
    end

    it "includes trip destination" do
      expect(mail.body.to_s).to include("Addis Ababa Airport")
    end

    it "includes requester contact details" do
      expect(mail.body.to_s).to include(requester.full_name)
    end

    it "includes vehicle plate number" do
      expect(mail.body.to_s).to include(vehicle.plate_number)
    end

    it "instructs driver to update trip status" do
      expect(mail.body.to_s).to include("update the trip status")
    end
  end

  describe "#assignment_notice_to_supervisor" do
    let(:disp_supervisor) { create(:user, :dispatcher_supervisor, department: department) }
    let(:mail) do
      TransportMailer.assignment_notice_to_supervisor(transport_request.id, disp_supervisor.id)
    end

    before { assignment }

    it "sends to the dispatcher supervisor" do
      expect(mail.to).to eq([disp_supervisor.email])
    end

    it "has the correct subject" do
      expect(mail.subject).to include("monitoring")
    end

    it "includes assignment summary details" do
      expect(mail.body.to_s).to include(driver.full_name)
      expect(mail.body.to_s).to include(vehicle.plate_number)
    end

    it "states no action is required" do
      expect(mail.body.to_s).to include("No action required")
    end
  end

  describe "#trip_status_notice" do
    let(:trip_update) do
      create(:trip_status_update, :started,
             transport_request: transport_request,
             driver:            driver,
             reported_at:       Time.current,
             note:              "Leaving HQ now")
    end

    let(:mail) { TransportMailer.trip_status_notice(transport_request.id, trip_update.id) }

    before { assignment }

    it "sends to the requester" do
      expect(mail.to).to eq([requester.email])
    end

    it "includes the status in the subject" do
      expect(mail.subject).to include("Started")
    end

    it "includes the driver name" do
      expect(mail.body.to_s).to include(driver.full_name)
    end

    it "includes the note" do
      expect(mail.body.to_s).to include("Leaving HQ now")
    end
  end
end