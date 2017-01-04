class Api::V1::UserConfirmationController < ApplicationController
  def create
    begin
      user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return render json: { message: "Could not find user" }, status: 404
    end
    NotifierMailer.confirm_user(user).deliver
    render status: 202
  end

  def update
    begin
      user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return render json: { message: "Could not find user" }, status: 404
    end
    user.confirm_user
    render status: 200
  end
end
