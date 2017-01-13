class Api::V1::TokensController < ApplicationController
  skip_before_action :authenticate

  def create
    # if user_params[:email]
    #   puts "Finding by email"
    #   user = User.find_by(email: user_params[:email])
    # elsif user_params[:username]
    #   puts "Finding by username"
    #   user = User.find_by(username: user_params[:username])
    # end
    user = User.where('username=? OR email=?', user_params[:searchinfo], user_params[:searchinfo]).first
    return render json: { jwt: Auth.issue(user: user.id), user: user.user_data } if user && user.authenticate(user_params[:password])
    render json: { message: "Invalid credentials" }, status: 401
  end

  private

  def user_params
    params.fetch(:auth, {}).permit(:searchinfo, :password)
  end
end
