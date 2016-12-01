require 'rails_helper'

module SessionsHelper
  module Requests
    def self.post_request(user)
      post api_v1_login_path, auth: { email: user.email, password: user.password }
    end
  end
end
