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
        post api_v1_searches_path, params: valid_search_params.merge(format: :json), headers: headers
      end

      it 'renders the results in JSON' do
        expect(ActiveSupport::JSON.decode(response.body)).not_to be nil
      end
    end

    context 'with invalid search parameters' do
      let(:invalid_search_params) { { dog: { } } }
      before do
        post api_v1_searches_path, params: invalid_search_params.merge(format: :json), headers: headers
      end

      it 'returns a 422 response' do
        expect(response.status).to eq(422)
      end

      it 'returns the error message' do
        expect(response.body).to eq(error_message)
      end
    end
  end
end