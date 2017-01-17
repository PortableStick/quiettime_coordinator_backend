class YelpSearch
  def self.fetch_results(params)
    if params[:name] && params[:name] != ""
      search_by_name(params[:name])
    elsif params[:latitude] && params[:longitude]
      search_by_coords(params[:latitude], params[:longitude])
    else
      { error: "No data sent" }
    end
  end

  def self.search_by_name(name)
    Yelp.client.search(name, search_params)
  end

  def self.search_by_coords(latitude, longitude)
    Yelp.client.search_by_coordinates({ latitude: latitude, longitude: longitude }, search_params)
  end

  def self.search_params
    {
      category_filter: "coffee"
    }
  end
end
