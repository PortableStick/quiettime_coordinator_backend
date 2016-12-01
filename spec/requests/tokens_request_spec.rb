require 'rails_helper'

RSpec.describe Api::V1::TokensController, type: :request do
  context "getting the token" do
    let(:user) { create(:user) }

    def error_message
      { message: "Invalid credentials" }.to_json
    end

    it 'status code is 200' do
      post "/api/v1/login", { auth: { email: user.email, password: user.password } }, { format: 'json', accept: 'application/json' }
      expect(last_response.status).to eq(200)
    end

    it "returns an error when given an invalid password" do
      post "/api/v1/login", { auth: { email: user.email, password: "nope" } }, { format: 'json', accept: 'application/json' }
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq(error_message)
    end

    it "returns an error when given no credentials" do
      post "/api/v1/login", { auth: { email: "", password: "" } }, { format: 'json', accept: 'application/json' }
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq(error_message)
    end

    it "returns an error when the request object format is invalid" do
      post "/api/v1/login", { nope: { email: "", password: "" } }, { format: 'json', accept: 'application/json' }
      expect(last_response).to_not be_ok
    end
  end
end
