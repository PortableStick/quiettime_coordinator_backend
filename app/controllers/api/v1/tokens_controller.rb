class Api::V1::TokensController < ApplicationController
  skip_before_action :authenticate

  def create
    user = User.where('username=? OR email=?', user_params[:searchinfo], user_params[:searchinfo]).first
    return render json: { user: user.user_data.merge(token: Auth.issue(user: user.id)) } if user && user.authenticate(user_params[:password])
    render json: { message: "Invalid credentials" }, status: 401
  end

  private

  def user_params
    params.fetch(:auth, {}).permit(:searchinfo, :password)
  end
end
