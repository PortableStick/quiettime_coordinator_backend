require 'rails_helper'

RSpec.describe PasswordResetsController, type: :request do
  let(:location) { create(:location) }
  let!(:user) { create(:user, plans: [location[:yelp_id]]) }
  let(:jwt) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }
  let(:headers) { { authorization: jwt } }

  def error_message
    { message: "No data or incorrect data sent" }.to_json
  end

  before do
    allow(User).to receive(:find_by).and_call_original
  end

  describe "POST create" do
    context "with a valid user and email" do
      def post_create
        post password_resets_path, params: { email: user.email }
      end

      it 'returns a 202 status' do
        post_create
        expect(response.status).to eq(202)
      end
    end

    context 'with no valid user' do
      def bad_create
        post password_resets_path, params: { email: "dog" }
      end

      it 'returns a 404 status' do
        bad_create
        expect(response.status).to eq(404)
      end

      it 'returns an error message in JSON' do
        bad_create
        expect(response.body).to eq({ message: "User not found" }.to_json)
      end
    end
  end

  describe "PATCH update" do
    context "with a valid user" do
      before { user.generate_password_reset_token }

      def patch_update
        patch password_reset_path(user.password_reset_token), params: { update: { password: "newpassword", password_confirmation: "newpassword" } }
      end

      it 'returns a 202 status' do
        patch_update
        expect(response.status).to eq(202)
      end

      it 'returns a new JWT' do
        patch_update
        expect(response.body).to eq({ jwt: jwt }.to_json)
      end
    end

    context "with no valid user" do
      def bad_update
        patch password_reset_path("dog"), params: { update: { password: "newpassword", password_confirmation: "newpassword" } }
      end

      it 'returns a 404 status' do
        bad_update
        expect(response.status).to eq(404)
      end

      it 'sends an error message' do
        bad_update
        expect(response.body).to eq({ message: "Invalid reset token" }.to_json)
      end
    end
  end
end