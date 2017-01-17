require 'rails_helper'

RSpec.describe Api::V1::UserConfirmationController, type: :request do
  let!(:user) { create(:user) }
  let(:jwt) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }
  let(:headers) { { authorization: jwt } }

  context "on successful confirmation" do
    it "returns a status of 200" do
      get api_v1_user_confirmation_path(user.id), headers: headers
      expect(response.status).to eq(202)
    end
  end

  context "on failure to find user" do
    it "returns a status of 404" do
      get api_v1_user_confirmation_path("dog"), headers: headers
      expect(response.status).to eq(404)
    end

    it "returns an error message" do
      get api_v1_user_confirmation_path("dog"), headers: headers
      expect(response.body).to eq({ message: "Could not find user" }.to_json)
    end
  end
end