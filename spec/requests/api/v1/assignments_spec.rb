require "rails_helper"

RSpec.describe "Api::V1::Assignments", type: :request do
  let(:department) { create(:department) }
  let(:dispatcher) { create(:user, :dispatcher, department: department) }
  let(:requester)  { create(:user, :requester,  department: department) }
  let(:driver)     { create(:driver) }
  let(:vehicle)    { create(:vehicle) }

  let(:approved_request) do
    create(:transport_request, :approved, requester: requester, department: department)
  end

  describe "POST /api/v1/transport_requests/:id/assignment" do
    let(:valid_params) do
      { assignment: { driver_id: driver.id, vehicle_id: vehicle.id } }
    end

    it "dispatcher assigns driver and vehicle to an approved request" do
      post "/api/v1/transport_requests/#{approved_request.id}/assignment",
           params:  valid_params.to_json,
           headers: auth_headers_for(dispatcher)

      expect(response).to have_http_status(:created)
      expect(approved_request.reload.status).to eq("assigned")
      expect(driver.reload.status).to eq("on_trip")
      expect(vehicle.reload.status).to eq("in_use")
    end

    it "returns error if request is not approved" do
      pending_request = create(:transport_request, :pending,
                               requester: requester, department: department)
      post "/api/v1/transport_requests/#{pending_request.id}/assignment",
           params:  valid_params.to_json,
           headers: auth_headers_for(dispatcher)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns error if request already has an assignment" do
      create(:assignment, transport_request: approved_request,
             driver: driver, vehicle: vehicle, dispatcher: dispatcher)
      approved_request.update!(status: :assigned)

      post "/api/v1/transport_requests/#{approved_request.id}/assignment",
           params:  valid_params.to_json,
           headers: auth_headers_for(dispatcher)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 403 for non-dispatcher" do
      post "/api/v1/transport_requests/#{approved_request.id}/assignment",
           params:  valid_params.to_json,
           headers: auth_headers_for(requester)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/transport_requests/:id/assignment" do
    it "returns assignment details" do
      assignment = create(:assignment, transport_request: approved_request,
                          driver: driver, vehicle: vehicle, dispatcher: dispatcher)
      approved_request.update!(status: :assigned)

      get "/api/v1/transport_requests/#{approved_request.id}/assignment",
          headers: auth_headers_for(dispatcher)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig("data", "id")).to eq(assignment.id.to_s)
    end
  end

  describe "notification side effects" do
    it "enqueues assignment notification job on create" do
      expect {
        post "/api/v1/transport_requests/#{approved_request.id}/assignment",
            params:  { assignment: { driver_id: driver.id, vehicle_id: vehicle.id } }.to_json,
            headers: auth_headers_for(dispatcher)
      }.to have_enqueued_job(AssignmentNotificationJob)
    end
  end
end