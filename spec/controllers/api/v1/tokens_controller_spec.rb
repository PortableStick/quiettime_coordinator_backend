require 'rails_helper'
require 'jwt'

RSpec.describe Api::V1::TokensController, type: :controller do
  context "authentication" do
    let(:user) { create(:user) }
    let(:token) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }
    let(:searchstr) { "username=? OR email=?" }

    it "finds the user via email" do
      expect(User).to receive(:where).with(searchstr, user.email, user.email).and_return([user])
      post :create, params: { auth: { searchinfo: user.email, password: user.password } }
    end

    it "finds the user via username" do
      expect(User).to receive(:where).with(searchstr, user.username, user.username).and_return([user])
      post :create, params: { auth: { searchinfo: user.username, password: user.password } }
    end

    it "authenticates the user via the given password" do
      allow(User).to receive(:where).with(searchstr, user.email, user.email).and_return([user])
      expect(user).to receive(:authenticate).with(user.password)
      post :create, params: { auth: { searchinfo: user.email, password: user.password } }
    end

    it "calls the Auth module to issue the jwt" do
      expect(Auth).to receive(:issue).with(user: user.id)
      post :create, params: { auth: { searchinfo: user.email, password: user.password } }
    end

    it "returns a jwt when given valid credentials" do
      expect(Auth).to receive(:issue).with(user: user.id).and_return(token)
      post :create, params: { auth: { searchinfo: user.email, password: user.password } }
    end
  end
end
