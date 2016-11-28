class Api::V1::SessionsController < ApplicationController
  def create
    user = User.find_by(email: user_params[:email])
  end

  private

  def user_params
    params.require(:auth).permit(:email, :password)
  end
end
