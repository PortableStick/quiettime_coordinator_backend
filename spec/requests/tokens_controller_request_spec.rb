require 'rails_helper'

RSpec.describe Api::V1::TokensController, type: :request do
  describe "getting the token" do
    let(:user) { create(:user) }
    let(:jwt) { { jwt: JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }.to_json }

    def error_message
      { message: "Invalid credentials" }.to_json
    end

    def post_login(auth_hash = { params: { auth: { email: user.email, password: user.password } } })
      post api_v1_tokens_path, auth_hash
    end

    context 'with valid credentials' do
      before do
        post_login
      end

      it 'has a status code of 200' do
        expect(response.status).to eq(200)
      end

      it 'sends the token' do
        expect(response.body).to eq(jwt)
      end
    end

    context 'with invalid credentials' do
      it "returns an error when given an invalid password" do
        post_login({ params: { auth: { email: user.email, password: "nope" } } })
        expect(response).to_not be_ok
        expect(response.body).to eq(error_message)
      end

      it "returns an error when given no credentials" do
        post_login({ params: { auth: { email: "", password: "" } } })
        expect(response).to_not be_ok
        expect(response.body).to eq(error_message)
      end

      it "returns an error when the request object format is invalid" do
        post_login({ params: { email: user.email, password: user.password } })
        expect(response).to_not be_ok
      end
    end
  end
end
