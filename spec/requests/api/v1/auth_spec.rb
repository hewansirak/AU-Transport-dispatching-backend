require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  let(:department) { create(:department) }
  let(:user)       { create(:user, email: "test@au.int", password: "Password1!", department: department) }

  describe "POST /api/v1/auth/login" do
    context "with valid credentials" do
      it "returns access and refresh tokens" do
        post "/api/v1/auth/login",
             params:  { auth: { email: user.email, password: "Password1!" } }.to_json,
             headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.dig("data", "access_token")).to be_present
        expect(json.dig("data", "refresh_token")).to be_present
        expect(json.dig("data", "user", "email")).to eq(user.email)
        expect(json.dig("data", "user", "role")).to eq(user.role)
      end
    end

    context "with invalid password" do
      it "returns 401" do
        post "/api/v1/auth/login",
             params:  { auth: { email: user.email, password: "wrongpassword" } }.to_json,
             headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid email or password")
      end
    end

    context "with unknown email" do
      it "returns 401" do
        post "/api/v1/auth/login",
             params:  { auth: { email: "nobody@au.int", password: "Password1!" } }.to_json,
             headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with inactive account" do
      it "returns 403" do
        user.update!(active: false)
        post "/api/v1/auth/login",
             params:  { auth: { email: user.email, password: "Password1!" } }.to_json,
             headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /api/v1/auth/me" do
    it "returns current user data" do
      get "/api/v1/auth/me", headers: auth_headers_for(user)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig("data", "email")).to eq(user.email)
    end

    it "returns 401 without token" do
      get "/api/v1/auth/me"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    it "returns success message" do
      delete "/api/v1/auth/logout", headers: auth_headers_for(user)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Logged out successfully")
    end
  end
end