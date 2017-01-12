class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate, only: [:create]

  def create
    user = User.create(user_params)
    if user.valid?
      NotifierMailer.confirm_user(user).deliver
      render json: { message: "User successfully created", user: user.user_data, jwt: Auth.issue(user: user.id) }, status: 201
    else
      render json: { message: "User could not be created", error: user.errors }, status: 400
    end
  end

  def update
    begin
      user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return render json: { message: "User could not be found" }, status: 404
    end
    if user
      user.update_attributes(update_params)
      render json: { message: "User successfully updated", user: user.user_data }, status: 202
    end
  end

  def destroy
    begin
      User.find(params[:id]).destroy
    rescue ActiveRecord::RecordNotFound
      return render json: { message: "User could not be found" }, status: 404
    end
    render json: { message: "User successfully deleted" }, status: 200
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def update_params
    params.require(:update).permit(:username, :email, :password, :password_confirmation)
  end
end
