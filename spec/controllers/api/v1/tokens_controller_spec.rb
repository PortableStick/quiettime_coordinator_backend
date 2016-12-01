require 'rails_helper'
require 'jwt'

RSpec.describe Api::V1::TokensController, type: :controller do
  context "authentication" do
    let(:user) { create(:user) }
    let(:token) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }

    it "finds the user" do
      expect(User).to receive(:find_by).with(email: user.email).and_return(user)
      post api_v1_login_path, auth: { email: user.email, password: user.password }
    end

    it "authenticates the user via the given password" do
      allow(User).to receive(:find_by).and_return(user)
      expect(user).to receive(:authenticate).with(user.password)
      post api_v1_login_path, auth: { email: user.email, password: user.password }
    end

    it "calls the Auth module to issue the jwt" do
      expect(Auth).to receive(:issue).with(user: user.id)
      post api_v1_login_path, auth: { email: user.email, password: user.password }
    end

    it "returns a jwt when given valid credentials" do
      expect(Auth).to receive(:issue).with(user: user.id).and_return(token)
      post api_v1_login_path, auth: { email: user.email, password: user.password }
    end
  end
end
