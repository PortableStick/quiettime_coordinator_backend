module SessionsHelper
  module Requests
    def post_request
      post :create, auth: { email: user.email, password: user.password }
    end
  end
end