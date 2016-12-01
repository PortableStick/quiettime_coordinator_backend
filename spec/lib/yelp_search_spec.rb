require 'rails_helper'
require 'yelp_search'

describe "YelpSearch" do
  describe '#search_by_name' do
    it 'calls Yelp::Client#search with all search parameters' do
      expect(Yelp.client).to receive(:search).with("Denver", search_params)
      YelpSearch.search_by_name("Denver")
    end
  end

  describe '#search_by_coords' do
    it 'calls Yelp::Client#search_by_coordinates with all search parameters' do
      expect(Yelp.client).to receive(:search_by_coordinates).with({latitude: "40.18187205354322", longitude: "-105.14008118978018"}, search_params)
      YelpSearch.search_by_coords("40.18187205354322", "-105.14008118978018")
    end
  end

  describe '#fetch_results' do
    it 'will only call #search_by_name when passed a name' do
      expect(YelpSearch).to receive(:search_by_name).with("Denver")
      YelpSearch.fetch_results({name: "Denver", latitude: "", longitude: ""})
    end

    it 'will call #search_by_coords when passed both coordinates and no name' do
      expect(YelpSearch).to receive(:search_by_coords).with("40.18187205354322", "-105.14008118978018")
      YelpSearch.fetch_results({name: "", latitude: "40.18187205354322", longitude: "-105.14008118978018"})
    end

    it 'will return an object of results if name input is valid' do
      mock_data = {"region": {}, "total": 0, "businesses": []}
      allow(Yelp.client).to receive(:search).with("Denver", search_params)
        .and_return(mock_data)
      results = YelpSearch.fetch_results({name: "Denver"})
      expect(results).to eq(mock_data)
    end

    it 'will return an object of results if coordinate input is valid' do
      mock_data = {"region": {}, "total": 0, "businesses": []}
      allow(Yelp.client).to receive(:search_by_coordinates).with({ latitude: "40.18187205354322", longitude: "-105.14008118978018" }, search_params)
        .and_return(mock_data)
      results = YelpSearch.fetch_results({ latitude: "40.18187205354322", longitude: "-105.14008118978018" })
      expect(results).to eq(mock_data)
    end

    it 'will return an error message if nothing is passed' do
      results = YelpSearch.fetch_results({})
      expect(results).to eq(error_msg)
    end
  end

  def search_params
    {
      category: "coffee"
    }
  end

  def error_msg
    { error: "No data sent" }
  end
end