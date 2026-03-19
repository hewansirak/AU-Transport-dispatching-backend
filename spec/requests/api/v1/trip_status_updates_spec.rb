require "rails_helper"

RSpec.describe "Api::V1::TripStatusUpdates", type: :request do
  let(:department)      { create(:department) }
  let(:dispatcher)      { create(:user, :dispatcher,  department: department) }
  let(:requester)       { create(:user, :requester,   department: department) }
  let(:driver_user)     { create(:user, :driver,      department: department) }
  let(:driver)          { create(:driver, user: driver_user) }
  let(:vehicle)         { create(:vehicle) }
  let(:assigned_request) do
    create(:transport_request, :assigned, requester: requester, department: department)
  end

  before do
    create(:assignment,
           transport_request: assigned_request,
           driver:            driver,
           vehicle:           vehicle,
           dispatcher:        dispatcher)
  end

  describe "POST /api/v1/transport_requests/:id/trip_status_updates" do
    it "assigned driver can post a started update" do
      post "/api/v1/transport_requests/#{assigned_request.id}/trip_status_updates",
           params:  { trip_status_update: { status: "started", note: "Leaving now" } }.to_json,
           headers: auth_headers_for(driver_user)

      expect(response).to have_http_status(:created)
      expect(assigned_request.reload.status).to eq("in_progress")
    end

    it "completing the trip frees the driver and vehicle" do
      post "/api/v1/transport_requests/#{assigned_request.id}/trip_status_updates",
           params:  { trip_status_update: { status: "completed" } }.to_json,
           headers: auth_headers_for(driver_user)

      expect(response).to have_http_status(:created)
      expect(assigned_request.reload.status).to eq("completed")
      expect(driver.reload.status).to eq("available")
      expect(vehicle.reload.status).to eq("available")
    end

    it "returns 403 for non-driver user" do
      post "/api/v1/transport_requests/#{assigned_request.id}/trip_status_updates",
           params:  { trip_status_update: { status: "started" } }.to_json,
           headers: auth_headers_for(requester)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/transport_requests/:id/trip_status_updates" do
    before do
      create(:trip_status_update, :started,  transport_request: assigned_request, driver: driver)
      create(:trip_status_update, :en_route, transport_request: assigned_request, driver: driver)
    end

    it "returns all status updates in order" do
      get "/api/v1/transport_requests/#{assigned_request.id}/trip_status_updates",
          headers: auth_headers_for(dispatcher)

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)["data"]
      expect(data.length).to eq(2)
      expect(data.first["attributes"]["status"]).to eq("started")
    end
  end

  describe "notification side effects" do
    it "enqueues a trip update notification when driver posts status" do
      expect {
        post "/api/v1/transport_requests/#{assigned_request.id}/trip_status_updates",
            params:  { trip_status_update: { status: "started" } }.to_json,
            headers: auth_headers_for(driver_user)
      }.to have_enqueued_job(TripUpdateNotificationJob)
    end
  end
end