require "rails_helper"

RSpec.describe "Api::V1::Vehicles", type: :request do
  let(:admin)      { create(:user, :admin) }
  let(:dispatcher) { create(:user, :dispatcher) }
  let(:requester)  { create(:user, :requester) }

  describe "GET /api/v1/vehicles" do
    before { create_list(:vehicle, 3) }

    it "returns all vehicles for dispatcher" do
      get "/api/v1/vehicles", headers: auth_headers_for(dispatcher)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"].length).to eq(3)
    end
  end

  describe "GET /api/v1/vehicles/available" do
    before do
      create_list(:vehicle, 2)
      create(:vehicle, :in_use)
      create(:vehicle, :maintenance)
    end

    it "returns only available vehicles for dispatcher" do
      get "/api/v1/vehicles/available", headers: auth_headers_for(dispatcher)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"].length).to eq(2)
    end

    it "returns 403 for requester" do
      get "/api/v1/vehicles/available", headers: auth_headers_for(requester)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/vehicles" do
    let(:valid_params) do
      {
        vehicle: {
          plate_number: "AU-TEST-01",
          make: "Toyota", model: "Prado",
          year: 2023, vehicle_type: "suv",
          capacity: 7, status: "available"
        }
      }
    end

    it "admin can create a vehicle" do
      post "/api/v1/vehicles",
           params:  valid_params.to_json,
           headers: auth_headers_for(admin)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body).dig("data", "attributes", "plate_number")).to eq("AU-TEST-01")
    end

    it "returns 403 for non-admin" do
      post "/api/v1/vehicles",
           params:  valid_params.to_json,
           headers: auth_headers_for(requester)

      expect(response).to have_http_status(:forbidden)
    end
  end
end