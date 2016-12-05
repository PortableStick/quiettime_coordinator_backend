require 'results_formatter'

class Api::V1::SearchesController < ApplicationController
  skip_before_action :authenticate, only: :create

  def create
    return error_message unless valid_search_params?
    results = ResultsFormatter.fetch_results(search_params, current_user)
    render json: results
  end

  def update
    return error_message unless valid_update_params?
    if current_user.add_location_to_plans(update_params[:yelp_id])
      begin
        if Location.find_or_create_by(yelp_id: update_params[:yelp_id], center: update_params[:center]).increment_attendence
          render json: { message: "Successful update" }, status: 202
        end
        rescue ActiveRecord::RecordNotFound || NoMethodError
          return render json: { message: "There was an internal error" }, status: 500
      end
    end
  end

  def destroy
    if current_user.remove_location_from_plans(params[:yelp_id])
      begin
        if Location.find_by(yelp_id: params[:yelp_id]).decrement_attendence
          return render json: { message: "Successful deletion" }, status: 200
        end
        rescue
          return render json: { message: "There was an internal error" }, status: 500
      end
    else
      return render json: { message: "User's plans didn't include location #{params[:yelp_id]}" }, status: 200
    end
  end

  private

  def search_params
    params.fetch(:search, {}).permit(:name, :latitude, :longitude)
  end

  def valid_search_params?
    search_params.include?(:name) || (search_params.include?(:latitude) && search_params.include?(:longitude))
  end

  def update_params
    params.fetch(:update, {}).permit(:yelp_id, :center)
  end

  def valid_update_params?
    update_params.include?(:yelp_id) && update_params.include?(:center)
  end

  def error_message
    render json: { message: "No data or incorrect data sent" }, status: 422
  end
end
