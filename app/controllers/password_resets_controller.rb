class PasswordResetsController < ApplicationController
  skip_before_action :authenticate

  def create
    user = User.find_by(email: user_params[:email])
    if user
      user.generate_password_reset_token
      NotifierMailer.password_reset(user).deliver
      render status: 202
    else
      render json: { message: "User not found" }, status: 404
    end
  end

  def update
    user = User.find_by(password_reset_token: params[:id])
    if user
      user.update_attributes(update_params)
      user.clear_reset_token
      render json: { jwt: Auth.issue(user: user.id) }, status: 202
    else
      render json: { message: "Invalid reset token" }, status: 404
    end
  end

  private

  def user_params
    params.permit(:email)
  end

  def update_params
    params.require(:update).permit(:password, :password_confirmation)
  end
end
