require 'rails_helper'

RSpec.describe PasswordResetsController, type: :request do
  let(:location) { create(:location) }
  let!(:user) { create(:user, plans: [location[:yelp_id]]) }
  let(:jwt) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }
  let(:headers) { { authorization: jwt } }

  def error_message
    { message: "No data or incorrect data sent" }.to_json
  end

  describe "POST create" do
    context "with a valid user and email" do
    end

    context 'with no valid user' do
      def bad_create
        post password_resets_path, params: { email: "dog" }
      end

      before do
        allow(User).to receive(:find_by).and_call_original
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
end