require 'rails_helper'
require 'jwt'

RSpec.describe Api::V1::SearchesController, type: :controller do
  let(:user) { create(:user) }
  let!(:token) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }
  let!(:invalid_token) { JWT.encode({ user: "dog" }, Rails.application.secrets.secret_key_base, 'HS256') }
  let(:valid_search_params) { { search: { name: "new york", latitude: "", longitude: "" }, format: :json } }
  let(:invalid_search_params) { { search: { dog: "face" } } }
  let(:valid_update_params) { { update: { yelp_id: "faceball", center: "10,10" } } }
  let(:invalid_update_params) { { update: { dog: "face" } } }
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

      describe "PATCH #update" do
        it "returns http success" do
          patch :update, params: valid_update_params
          expect(response).to have_http_status(:success)
        end

        it 'calls #add_location_to_plans for current_user' do
          expect(user).to receive(:add_location_to_plans).and_return(true)
          patch :update, params: valid_update_params
        end

        it 'checks for valid update parameters' do
          expect(controller).to receive(:valid_update_params?).and_return true
          patch :update, params: valid_update_params
        end

        context 'and if the user was updated successfully' do
          before do
            expect(user).to receive(:add_location_to_plans).and_return(user)
          end

          it 'calls #find_or_create_by on the location model' do
            expect(Location).to receive(:find_or_create_by).with(yelp_id: valid_update_params[:update][:yelp_id], center: valid_update_params[:update][:center]).and_return(location)
            patch :update, params: valid_update_params
          end

          it 'calls #increment_attendence on the found or create location' do
            allow(Location).to receive(:find_or_create_by).and_return(location)
            expect(location).to receive(:increment_attendence)
            patch :update, params: valid_update_params
          end
        end
      end

      describe "DELETE #destroy" do
        let(:valid_delete_params) { { yelp_id: location[:yelp_id] } }
        before do
          allow(controller).to receive(:current_user).and_return(user)
        end

        it "calls #remove_location_from_plans on current_user" do
          expect(user).to receive(:remove_location_from_plans)
          delete :destroy, params: valid_delete_params
        end

        it "passes the yelp_id param to #remove_location_from_plans" do
          expect(user).to receive(:remove_location_from_plans).with(valid_delete_params[:yelp_id])
          delete :destroy, params: valid_delete_params
        end

        context "if the plan is removed from the user" do
          before do
            allow(user).to receive(:remove_location_from_plans).and_return user
          end

          it 'calls finds the location by the yelp_id param' do
            expect(Location).to receive(:find_by).with(yelp_id: valid_delete_params[:yelp_id])
            delete :destroy, params: valid_delete_params
          end

          it 'calls #decrement_attendence on the found location' do
            allow(Location).to receive(:find_by).and_return(location)
            expect(location).to receive(:decrement_attendence)
            delete :destroy, params: valid_delete_params
          end
        end

        context "if the plan is not removed from the user" do
          before do
            allow(user).to receive(:remove_location_from_plans).and_return false
          end
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

      describe 'PATCH #update' do
        before do
          allow(controller).to receive(:update_params).and_return(invalid_update_params)
        end

        it 'calls #error_message' do
          expect(controller).to receive(:error_message)
          patch :update
        end
      end
    end
  end

  context 'and an invalid token' do
    before do
      controller.request.env["HTTP_AUTHORIZATION"] = invalid_token
    end

    describe "PATCH #update" do
      it "returns http success" do
        patch :update, params: {}
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "DELETE #destroy" do
      it "returns http success" do
        delete :destroy, params: { yelp_id: 1 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
