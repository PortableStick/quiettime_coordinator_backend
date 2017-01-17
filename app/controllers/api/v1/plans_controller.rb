class Api::V1::PlansController < ApplicationController
  def create
    return error_message unless valid_update_params?
    if current_user.add_location_to_plans(update_params[:yelp_id])
      begin
        if Location.find_or_create_by(yelp_id: update_params[:yelp_id], center: update_params[:center]).increment_attendence
          render json: { message: "Successful update", user: { plans: current_user.plans } }, status: 202
        end
        rescue ActiveRecord::RecordNotFound || NoMethodError
          return render json: { message: "There was an internal error" }, status: 500
      end
    end
  end

  def destroy
   if current_user.remove_location_from_plans(params[:id])
    begin
      if Location.find_by(yelp_id: params[:id]).decrement_attendence
        return render json: { message: "Successful deletion", user: { plans: current_user.plans } }, status: 200
      end
      rescue
        return render json: { message: "There was an internal error" }, status: 500
      end
    else
      return render json: { message: "User's plans didn't include location #{params[:id]}", user: { plans: current_user.plans } }, status: 200
    end
  end

  private

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
