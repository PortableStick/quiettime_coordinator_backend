require 'rails_helper'

RSpec.describe Api::V1::SearchesController, type: :request do
  let(:location) { create(:location) }
  let(:user) { create(:user, plans: [location[:yelp_id]]) }
  let(:jwt) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }
  let(:headers) { { authorization: jwt } }

  def error_message
    { message: "No data or incorrect data sent" }.to_json
  end

  describe '#create' do
    yelp_results = JSON.parse(File.read(Rails.root.join('spec/yelp_results.json')))

    context 'with valid search parameters' do
      let(:valid_search_params) { { search: { name: "new york" } } }
      before do
        allow(YelpSearch).to receive(:fetch_results).and_return(yelp_results)
        post "/api/v1/search", params: valid_search_params.merge(format: :json), headers: headers
      end

      it 'renders the results in JSON' do
        expect(ActiveSupport::JSON.decode(response.body)).not_to be nil
      end
    end

    context 'with invalid search parameters' do
      let(:invalid_search_params) { { dog: { } } }
      before do
        post "/api/v1/search", params: invalid_search_params.merge(format: :json), headers: headers
      end

      it 'returns a 422 response' do
        expect(response.status).to eq(422)
      end

      it 'returns the error message' do
        expect(response.body).to eq(error_message)
      end
    end
  end

  describe '#update' do
    context 'with valid update parameters' do
      let(:valid_update_params) { { update: { yelp_id: "something", center: "10,10"} } }
      let(:location) { build(:location) }

      context 'and the Location update is successful' do
        before do
          allow(Location).to receive(:find_or_create_by).and_return(location)
          allow(location).to receive(:increment_attendence).and_return true
          patch "/api/v1/attending", params: valid_update_params.merge(format: :json), headers: headers
        end

        it 'returns a status of 202' do
          expect(response.status).to eq(202)
        end

        it 'returns a success message' do
          expect(response.body).to eq({ message: "Successful update" }.to_json)
        end
      end

      context 'and the location cannot be found or created' do
        before do
          allow(Location).to receive(:find_or_create_by).and_raise(ActiveRecord::RecordNotFound)
          patch "/api/v1/attending", params: valid_update_params.merge(format: :json), headers: headers
        end

        it 'returns a status of 500' do
          expect(response.status).to eq(500)
        end

        it 'returns an error message' do
          expect(response.body).to eq({ message: "There was an internal error" }.to_json)
        end
      end
    end

    context 'with invalid update parameters' do
      let(:invalid_update_params) { { dog: { } } }
      before do
        patch "/api/v1/attending", params: invalid_update_params.merge(format: :json), headers: headers
      end

      it 'returns a 422 response' do
        expect(response.status).to eq(422)
      end

      it 'returns the error message' do
        expect(response.body).to eq(error_message)
      end
    end
  end

  describe '#delete' do
    context 'with valid delete parameters' do
      before do
        allow(Location).to receive(:find_by).and_return(location)
        allow(location).to receive(:decrement_attendence).and_return(true)
      end

      context 'on successful deletion' do
        before do
          delete "/api/v1/attending/#{location[:yelp_id]}", headers: headers
        end

        it 'returns a 200 status' do
          expect(response.status).to eq(200)
        end

        it 'renders a success message in JSON' do
          expect(response.body).to eq({ message: "Successful deletion" }.to_json)
        end
      end

    end

    context 'when user\'s plans do not include the given parameter' do
      let(:invalid_delete_params) { { yelp_id: "dog" } }

      before do
        allow(user).to receive(:remove_location_from_plans).and_return false
        delete "/api/v1/attending/dog", headers: headers
      end

      it 'returns a 200 status' do
        expect(response.status).to eq(200)
      end

      it 'renders an error message in JSON' do
        expect(response.body).to eq({ message: "User's plans didn't include location #{invalid_delete_params[:yelp_id]}" }.to_json)
      end
    end
  end
end