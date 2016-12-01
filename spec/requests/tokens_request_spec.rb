require 'rails_helper'

RSpec.describe Api::V1::TokensController, type: :request do
  context "getting the token" do
    let(:user) { create(:user) }

    def error_message
      { message: "Invalid credentials" }.to_json
    end

    def post_login(auth_hash = { auth: { email: user.email, password: user.password } })
      post "/api/v1/login", auth_hash, { format: 'json', accept: 'application/json' }
    end

    it 'status code is 200' do
      post_login
      expect(last_response.status).to eq(200)
    end

    it "returns an error when given an invalid password" do
      post_login({ auth: { email: user.email, password: "nope" } })
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq(error_message)
    end

    it "returns an error when given no credentials" do
      post_login({ auth: { email: "", password: "" } })
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq(error_message)
    end

    it "returns an error when the request object format is invalid" do
      post_login({ email: user.email, password: user.password })
      expect(last_response).to_not be_ok
    end
  end
end
