require 'rails_helper'
require 'results_formatter'
yelp_results = JSON.parse(File.read(Rails.root.join('spec/yelp_results.json')))
center = "#{yelp_results["region"]["center"]["latitude"]},#{yelp_results["region"]["center"]["longitude"]}"

describe 'ResultsFormatter' do
  let(:current_user) { build(:user) }
  let!(:location) {
      create(:location,
              yelp_id: yelp_results["businesses"][Random.rand(yelp_results["businesses"].count)]["yelp_id"],
              center: center )
    }
  let(:locations) { { location["yelp_id"] => location["attending"] } }
  let(:params) { { name: "new york city" } }

  context 'self#fetch_results' do
    it 'calls YelpSearch#fetch_results with the proper params' do
      expect(YelpSearch).to receive(:fetch_results).with(params).and_return(yelp_results)
      ResultsFormatter.fetch_results(params, current_user)
    end

    describe 'the format of the results' do
      let(:results) { ResultsFormatter.fetch_results(params, current_user) }
      let!(:formatted_businesses) { yelp_results["businesses"].map do |result|
          {
            rating: result["rating"],
            url: result["url"],
            name: result["name"],
            image_url: result["image_url"],
            snippet_text: result["snippet_text"],
            id: result["id"],
            review_count: result["review_count"],
            user_going: current_user ? current_user["plans"].include?(result["id"]) : false,
            attending: locations[result["id"]] ? locations[result["id"]] : 0
          }
        end
       }

      before do
        allow(YelpSearch).to receive(:fetch_results).with(params).and_return(yelp_results)
      end

      it 'should include the coordinates as the property "center"' do
        expect(results[:center]).to eq(center)
      end

      it 'should return all of the businesses in an array' do
        expect(results[:results]).to be_an(Array)
        expect(results[:results].count).to eq(yelp_results["businesses"].count)
      end

      it 'should return its data in the expected shape' do
        expect(results[:results]).to eq(formatted_businesses)
      end
    end
  end
end