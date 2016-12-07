require 'rails_helper'

RSpec.describe Api::V1::PlansController, type: :controller do
  let(:location) { create(:location) }
  let(:user) { create(:user) }
  let!(:token) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }
  let!(:invalid_token) { JWT.encode({ user: "dog" }, Rails.application.secrets.secret_key_base, 'HS256') }
  let(:valid_update_params) { { update: { yelp_id: location[:yelp_id], center: location[:center] } } }
  let(:invalid_update_params) { { update: { yelp_id: "dog", smurrr: "" } } }

  def post_create
    post :create, params: valid_update_params
  end

  context 'with a valid token' do
    before do
      controller.request.env["HTTP_AUTHORIZATION"] = token
      allow(controller).to receive(:current_user).and_return(user)
    end
    describe "POST #create" do
      it "returns http success" do
        post_create
        expect(response).to have_http_status(:success)
      end

      it 'calls #add_location_to_plans for current_user' do
        expect(user).to receive(:add_location_to_plans).and_return(true)
        post_create
      end

      it 'calls #update_params and receives a parsed update_params object' do
        allow(controller).to receive(:valid_update_params?).and_return true
        expect(controller).to receive(:update_params).and_call_original.at_least(:once)
        post_create
      end

      it 'validates update_params with #valid_update_params?' do
        allow(controller).to receive(:update_params).and_call_original
        expect(controller).to receive(:valid_update_params?).and_return(true).at_least(:once)
        post_create
      end

      context 'and if the user was updated successfully' do
        before do
          expect(user).to receive(:add_location_to_plans).and_return(user)
        end

        it 'calls #find_or_create_by on the location model' do
          expect(Location).to receive(:find_or_create_by).with(yelp_id: valid_update_params[:update][:yelp_id], center: valid_update_params[:update][:center]).and_return(location)
          post_create
        end

        it 'calls #increment_attendence on the found or create location' do
          allow(Location).to receive(:find_or_create_by).and_return(location)
          expect(location).to receive(:increment_attendence)
          post_create
        end
      end
    end

    describe "DELETE #destroy" do
      let(:valid_delete_params) { { id: location[:yelp_id] } }
        before do
          allow(controller).to receive(:current_user).and_return(user)
        end

      it "returns http success" do
        delete :destroy, params: { id: location[:yelp_id] }
        expect(response).to have_http_status(:success)
      end

      it "calls #remove_location_from_plans on current_user" do
        expect(user).to receive(:remove_location_from_plans)
        delete :destroy, params: valid_delete_params
      end

      it "passes the yelp_id param to #remove_location_from_plans" do
        expect(user).to receive(:remove_location_from_plans).with(valid_delete_params[:id])
        delete :destroy, params: valid_delete_params
      end

      context "if the plan is removed from the user" do
        before do
          allow(user).to receive(:remove_location_from_plans).and_return user
        end

        it 'calls finds the location by the yelp_id param' do
          expect(Location).to receive(:find_by).with(yelp_id: valid_delete_params[:id])
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
      before do
        controller.request.env["HTTP_AUTHORIZATION"] = token
        allow(controller).to receive(:update_params).and_return(invalid_update_params)
      end

      it 'calls #error_message' do
        expect(controller).to receive(:error_message)
        post :create, params: { dookie: "" }
      end
    end
  end
end
