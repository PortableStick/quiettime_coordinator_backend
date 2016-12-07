class PasswordResetsController < ApplicationController
  skip_before_action :authenticate

  def create
    user = User.find_by(email: user_params[:email])
    if user
      user.generate_password_reset_token
      NotifierMailer.password_reset(user).deliver
    else
      render json: { message: "User not found" }, status: 404
    end
  end

  private

  def user_params
    params.permit(:email)
  end
end
