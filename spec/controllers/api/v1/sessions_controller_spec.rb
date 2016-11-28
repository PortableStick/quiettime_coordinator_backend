require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  context "authorization" do
    let(:user) { create(:user) }

    it "finds the user" do
      expect(User).to receive(:find_by).with(email: user.email).and_return(user)
    end

    it "calls the Auth module to issue the jwt" do
      expect(Auth).to receive(:issue).with(user: user.id)
      SessionsHelper::Requests.post_request
    end

    it "returns a jwt when given valid credentials" do
    end

    it "returns an error when given and invalid username" do
    end

    it "returns an error when given and invalid password" do
    end

    it "returns an error when given no credentials" do
    end

    it "returns an error when the request object format is invalid" do
    end
  end
end
