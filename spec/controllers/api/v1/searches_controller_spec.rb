require 'rails_helper'
require 'jwt'

RSpec.describe Api::V1::SearchesController, type: :controller do
  let(:user) { create(:user) }
  let!(:token) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }
  let!(:invalid_token) { JWT.encode({ user: "dog" }, Rails.application.secrets.secret_key_base, 'HS256') }
  let(:valid_search_params) { { search: { name: "new york", latitude: "", longitude: "" }, format: :json } }
  let(:invalid_search_params) { { search: { dog: "face" } } }
  let(:location) { create(:location) }

  context 'with a valid token' do
    before do
      controller.request.env["HTTP_AUTHORIZATION"] = token
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'and valid input' do
      describe "POST #create" do
        it "returns http success" do
          allow(ResultsFormatter).to receive(:fetch_results)
          post :create, params: valid_search_params
          expect(response).to have_http_status(:success)
        end

        it 'calls #search_params to get the correct parameters' do
          allow(ResultsFormatter).to receive(:fetch_results)
          expect(controller).to receive(:search_params).and_call_original.at_least(:once)
          post :create, params: valid_search_params
        end

        it 'calls ResultsFormatter#fetch_results with parameters' do
          expect(ResultsFormatter).to receive(:fetch_results).and_return({})
          post :create, params: valid_search_params
        end

        it 'checks for valid search parameters' do
          allow(ResultsFormatter).to receive(:fetch_results)
          expect(controller).to receive(:valid_search_params?).and_return true
          post :create, params: valid_search_params
        end
      end
    end

    context 'and invalid input' do
      describe 'POST #create' do
        it 'returns unprocessable_entity status' do
          allow(ResultsFormatter).to receive(:fetch_results)
          post :create, params: invalid_search_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'checks for valid search parameters' do
          allow(ResultsFormatter).to receive(:fetch_results)
          expect(controller).to receive(:valid_search_params?).and_return false
          post :create, params: invalid_search_params
        end

        it 'calls #error_message' do
          expect(controller).to receive(:error_message)
          post :create, params: invalid_search_params
        end
      end
    end
  end
end
