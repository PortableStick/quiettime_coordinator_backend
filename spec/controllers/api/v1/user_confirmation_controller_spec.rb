require 'rails_helper'

RSpec.describe Api::V1::UserConfirmationController, type: :controller do

  let(:user) { create(:user) }
  let!(:token) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }

  before do
    controller.request.env["HTTP_AUTHORIZATION"] = token
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "POST #create" do
    context "with a valid user id" do
      def post_create
        post :create, params: { id: user.id }
      end

      it "returns https success" do
        post_create
        expect(response).to have_http_status(:success)
      end

      it "finds the user" do
        expect(User).to receive(:find).with(user.id.to_s).and_return(user)
        post_create
      end

      it "sends out a user confirmation email" do
        expect{ post_create }.to change(ActionMailer::Base.deliveries, :size)
      end

      it "returns a status of 202" do
        post_create
        expect(response.status).to eq(202)
      end
    end

    context "with an invalid user id" do
      def post_create
        post :create, params: { id: "dog" }
      end

      it "returns a status of 404" do
        post_create
        expect(response.status).to eq(404)
      end

      it "returns a failure message" do
        post_create
        expect(response.body).to eq({ message: "Could not find user" }.to_json)
      end
    end
  end

  describe "PUT #update" do
    def put_update
      put :update, params: { id: user.id }
    end

    it "returns http success" do
      put_update
      expect(response).to have_http_status(:success)
    end

    it "finds the user" do
      expect(User).to receive(:find).with(user.id.to_s).and_return(user)
      put_update
    end

    it "calls confirm_user on the user" do
      allow(User).to receive(:find).and_return(user)
      expect(user).to receive(:confirm_user)
      put_update
    end
  end

end
