require "rails_helper"

RSpec.describe "Api::V1::Drivers", type: :request do
  let(:admin)      { create(:user, :admin) }
  let(:dispatcher) { create(:user, :dispatcher) }
  let(:requester)  { create(:user, :requester) }

  describe "GET /api/v1/drivers" do
    before { create_list(:driver, 3) }

    it "dispatcher can list drivers" do
      get "/api/v1/drivers", headers: auth_headers_for(dispatcher)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"].length).to eq(3)
    end

    it "requester cannot list drivers" do
      get "/api/v1/drivers", headers: auth_headers_for(requester)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/drivers/available" do
    before do
      create_list(:driver, 2)
      create(:driver, :on_trip)
      create(:driver, :off_duty)
    end

    it "returns only available drivers" do
      get "/api/v1/drivers/available", headers: auth_headers_for(dispatcher)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"].length).to eq(2)
    end
  end

  describe "GET /api/v1/drivers/:id/assignments" do
    let(:driver) { create(:driver) }

    before do
      dept = create(:department)
      req  = create(:user, :requester, department: dept)
      3.times do
        tr = create(:transport_request, :assigned, requester: req, department: dept)
        create(:assignment, transport_request: tr, driver: driver,
               vehicle: create(:vehicle), dispatcher: dispatcher)
      end
    end

    it "returns assignment history for driver" do
      get "/api/v1/drivers/#{driver.id}/assignments",
          headers: auth_headers_for(dispatcher)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"].length).to eq(3)
    end
  end
end