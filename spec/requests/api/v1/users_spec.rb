require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  let(:admin)     { create(:user, :admin) }
  let(:requester) { create(:user, :requester) }

  describe "GET /api/v1/users" do
    before { create_list(:user, 3) }

    it "admin can list users" do
      get "/api/v1/users", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
    end

    it "requester cannot list users" do
      get "/api/v1/users", headers: auth_headers_for(requester)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/users/:id" do
    it "user can view their own profile" do
      get "/api/v1/users/#{requester.id}", headers: auth_headers_for(requester)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig("data", "attributes", "email")).to eq(requester.email)
    end

    it "user cannot view another user's profile" do
      other = create(:user)
      get "/api/v1/users/#{other.id}", headers: auth_headers_for(requester)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/users/:id (deactivate)" do
    it "admin can deactivate a user" do
      target = create(:user)
      delete "/api/v1/users/#{target.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(target.reload.active).to be false
    end

    it "requester cannot deactivate users" do
      target = create(:user)
      delete "/api/v1/users/#{target.id}", headers: auth_headers_for(requester)
      expect(response).to have_http_status(:forbidden)
    end
  end
end