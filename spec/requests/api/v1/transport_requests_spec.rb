require "rails_helper"

RSpec.describe "Api::V1::TransportRequests", type: :request do
  let(:department)  { create(:department) }
  let(:requester)   { create(:user, :requester,  department: department) }
  let(:supervisor)  { create(:user, :supervisor, department: department) }
  let(:dispatcher)  { create(:user, :dispatcher, department: department) }
  let(:admin)       { create(:user, :admin,       department: department) }

  let(:valid_params) do
    {
      transport_request: {
        originator_office:   "HR Office",
        telephone_extension: "1234",
        required_date:       5.days.from_now.to_date.to_s,
        required_from_time:  "09:00",
        required_to_time:    "12:00",
        working_hours:       true,
        destination:         "Addis Ababa Airport",
        purpose:             "Staff pickup for delegation",
        service_type:        "passenger",
        passenger_count:     3
      }
    }
  end

  describe "GET /api/v1/transport_requests" do
    before do
      create_list(:transport_request, 3, requester: requester, department: department)
      create(:transport_request, department: department) # belongs to another user
    end

    it "requester only sees their own requests" do
      get "/api/v1/transport_requests", headers: auth_headers_for(requester)
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)["data"]
      expect(data.length).to eq(3)
    end

    it "supervisor sees all requests in their department" do
      get "/api/v1/transport_requests", headers: auth_headers_for(supervisor)
      expect(response).to have_http_status(:ok)
      # 3 + 1 because the 4th also belongs to the department
      expect(JSON.parse(response.body)["data"].length).to eq(4)
    end

    it "dispatcher sees all requests" do
      get "/api/v1/transport_requests", headers: auth_headers_for(dispatcher)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"].length).to eq(4)
    end
  end

  describe "POST /api/v1/transport_requests" do
    it "requester creates a request successfully" do
      post "/api/v1/transport_requests",
           params:  valid_params.to_json,
           headers: auth_headers_for(requester)

      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)["data"]
      expect(data["attributes"]["status"]).to eq("pending")
      expect(data["attributes"]["destination"]).to eq("Addis Ababa Airport")
    end

    it "sets requester and department automatically" do
      post "/api/v1/transport_requests",
           params:  valid_params.to_json,
           headers: auth_headers_for(requester)

      tr = TransportRequest.last
      expect(tr.requester).to eq(requester)
      expect(tr.department).to eq(requester.department)
    end

    it "returns errors for invalid data" do
      post "/api/v1/transport_requests",
           params:  { transport_request: { destination: "" } }.to_json,
           headers: auth_headers_for(requester)

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end

    it "requires passenger_count when service_type is passenger" do
      params = valid_params.deep_merge(transport_request: { passenger_count: nil })
      post "/api/v1/transport_requests",
           params:  params.to_json,
           headers: auth_headers_for(requester)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/v1/transport_requests/:id/approve" do
    let(:pending_request) do
      create(:transport_request, :pending, requester: requester, department: department)
    end

    it "supervisor can approve a pending request" do
      post "/api/v1/transport_requests/#{pending_request.id}/approve",
           headers: auth_headers_for(supervisor)

      expect(response).to have_http_status(:ok)
      expect(pending_request.reload.status).to eq("approved")
      expect(pending_request.reviewed_by).to eq(supervisor)
    end

    it "requester cannot approve" do
      post "/api/v1/transport_requests/#{pending_request.id}/approve",
           headers: auth_headers_for(requester)

      expect(response).to have_http_status(:forbidden)
    end

    it "dispatcher cannot approve" do
      post "/api/v1/transport_requests/#{pending_request.id}/approve",
           headers: auth_headers_for(dispatcher)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/transport_requests/:id/reject" do
    let(:pending_request) do
      create(:transport_request, :pending, requester: requester, department: department)
    end

    it "supervisor can reject with a reason" do
      post "/api/v1/transport_requests/#{pending_request.id}/reject",
           params:  { transport_request: { rejection_reason: "Not justified" } }.to_json,
           headers: auth_headers_for(supervisor)

      expect(response).to have_http_status(:ok)
      expect(pending_request.reload.status).to eq("rejected")
      expect(pending_request.rejection_reason).to eq("Not justified")
    end

    it "returns error when rejection_reason is blank" do
      post "/api/v1/transport_requests/#{pending_request.id}/reject",
           params:  { transport_request: { rejection_reason: "" } }.to_json,
           headers: auth_headers_for(supervisor)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /api/v1/transport_requests/:id" do
    it "requester can cancel their own pending request" do
      tr = create(:transport_request, :pending, requester: requester, department: department)
      delete "/api/v1/transport_requests/#{tr.id}", headers: auth_headers_for(requester)
      expect(response).to have_http_status(:ok)
      expect(tr.reload.status).to eq("cancelled")
    end

    it "requester cannot cancel an approved request" do
      tr = create(:transport_request, :approved, requester: requester, department: department)
      delete "/api/v1/transport_requests/#{tr.id}", headers: auth_headers_for(requester)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "notification side effects" do
    before { ActionMailer::Base.deliveries.clear }

    it "enqueues an approval email when approved" do
      pending_request = create(:transport_request, :pending,
                              requester: requester, department: department)
      expect {
        post "/api/v1/transport_requests/#{pending_request.id}/approve",
            headers: auth_headers_for(supervisor)
      }.to have_enqueued_job(ApprovalNotificationJob)
    end

    it "enqueues a rejection email when rejected" do
      pending_request = create(:transport_request, :pending,
                              requester: requester, department: department)
      expect {
        post "/api/v1/transport_requests/#{pending_request.id}/reject",
            params:  { transport_request: { rejection_reason: "Not justified" } }.to_json,
            headers: auth_headers_for(supervisor)
      }.to have_enqueued_job(RejectionNotificationJob)
    end
  end
end