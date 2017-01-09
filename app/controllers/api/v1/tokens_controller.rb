class Api::V1::TokensController < ApplicationController
  skip_before_action :authenticate

  def create
    user = User.find_by(email: user_params[:email])
    return render json: { jwt: Auth.issue(user: user.id), user: user } if user && user.authenticate(user_params[:password])
    render json: { message: "Invalid credentials" }, status: 401
  end

  private

  def user_params
    params.fetch(:auth, {}).permit(:email, :password)
  end
end
