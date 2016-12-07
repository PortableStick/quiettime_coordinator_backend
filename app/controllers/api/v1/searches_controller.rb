require 'results_formatter'

class Api::V1::SearchesController < ApplicationController
  skip_before_action :authenticate, only: :create

  def create
    return error_message unless valid_search_params?
    results = ResultsFormatter.fetch_results(search_params, current_user)
    render json: results
  end

  private

  def search_params
    params.fetch(:search, {}).permit(:name, :latitude, :longitude)
  end

  def valid_search_params?
    search_params.include?(:name) || (search_params.include?(:latitude) && search_params.include?(:longitude))
  end

  def error_message
    render json: { message: "No data or incorrect data sent" }, status: 422
  end
end
