class ApplicationController < ActionController::API
  before_action :authenticate

  def current_user
    if auth_present?
      begin
        @current_user ||= User.find(auth["user"])
      rescue ActiveRecord::RecordNotFound
        return render json: { message: "User not found" }, status: 404
      end
    else
      @current_user = nil
    end
  end

  def logged_in?
    !!current_user
  end

  def authenticate
    render json: { message: "Unauthorized access" }, status: 403 unless logged_in?
  end

  private

  def auth
    Auth.decode(token)
  end

  def token
    request.env["HTTP_AUTHORIZATION"]
  end

  def auth_present?
    !request.headers[:HTTP_AUTHORIZATION].nil?
    # !request.env.fetch("HTTP_AUTHORIZATION").nil?
  end
end
