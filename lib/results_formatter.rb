class ResultsFormatter
  def self.fetch_results(params, current_user)
    results = YelpSearch.fetch_results(params)
    latitude = results.region.center.latitude
    longitude = results.region.center.longitude
    center = "#{latitude},#{longitude}"
    locations = Location.where(center: center).to_a.each_with_object({}) do |curr, prev|
      prev[curr.yelp_id] = curr.attending
    end
    {
      center: center,
      results: results.businesses.map do |result|
        {
          rating: result.rating,
          url: result.url,
          name: result.name,
          image_url: result.image_url,
          snippet_text: result.snippet_text,
          id: result.id,
          review_count: result.review_count,
          user_going: current_user ? current_user.plans.include?(result.id) : false,
          attending: locations[result.id] ? locations[result.id] : 0
        }
      end
    }
  end
end
