require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:user) { create(:user) }
  let!(:token) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }

  before do
    controller.request.env["HTTP_AUTHORIZATION"] = token
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "POST #create" do
    let!(:create_params) { { user: { username: "dog1", email: "dog@dogville.com", password: "supercanineman", password_confirmation: "supercanineman" } } }
    let(:strong_create_params) { ActionController::Parameters.new(create_params).require(:user).permit(:username, :email, :password, :password_confirmation) }

    def post_create
      post :create, params: create_params
    end

    it "returns http success" do
      post_create
      expect(response).to have_http_status(:success)
    end

    it "does not invoke #authenticate" do
      expect(controller).to_not receive(:authenticate)
      post_create
    end

    it "calls #user_params to get the new user's parameters" do
      expect(controller).to receive(:user_params).and_return strong_create_params
      post_create
    end

    it "passes the user params to User#create!" do
      expect(User).to receive(:create).with(strong_create_params).and_return(user)
      post_create
    end

    context "when it passes validation" do
      it "it creates a new user" do
        post_create
        expect(User.find_by(email: "dog@dogville.com").username).to eq("dog1")
      end

      it "it sends a user confirmation email" do
        expect{ post_create }.to change(ActionMailer::Base.deliveries, :size)
      end
    end
  end

  describe "PATCH #update" do

    let(:update_params) { { update: { username: "dogstar", email: "b@a.com", password: "huunuunuu", password_confirmation: "huunuunuu" } } }
    let(:strong_update_params) { ActionController::Parameters.new(update_params).require(:update).permit(:username, :email, :password, :password_confirmation) }

    def patch_update
      patch :update, params: { id: user.id }.merge(update_params)
    end

    it "returns http success" do
      patch_update
      expect(response).to have_http_status(:success)
    end

    it "finds the user" do
      expect(User).to receive(:find).with(user.id.to_s).and_return(user)
      patch_update
    end

    it "calls #update_params to get the user's new paramters" do
      expect(controller).to receive(:update_params).and_return(strong_update_params)
      patch_update
    end

    it "passes the user's update params to User#update_attributes" do
      allow(User).to receive(:find).and_return(user)
      expect(user).to receive(:update_attributes).with(strong_update_params)
      patch_update
    end

    describe "changes the user's attributes" do
      it "changes the username" do
        expect{ patch_update; user.reload }.to change{ user.username }
      end

      it "changes the email" do
        expect{ patch_update; user.reload }.to change{ user.email }
      end

      it "changes the password" do
        expect{ patch_update; user.reload }.to change{ user.password_digest }
      end
    end
  end

  describe "GET #destroy" do
    def delete_destroy
      delete :destroy, params: { id: user.id }
    end

    it "returns http success" do
      delete_destroy
      expect(response).to have_http_status(:success)
    end

    it "finds the user with the passed param" do
      expect(User).to receive(:find).with(user.id.to_s).and_return user
      delete_destroy
    end

    it "calls #destroy on the found user" do
      allow(User).to receive(:find).and_return user
      expect(user).to receive(:destroy)
      delete_destroy
    end

    it "deletes the user" do
      allow(User).to receive(:find).and_return user
      expect{ delete_destroy }.to change(User, :count).by(-1)
    end
  end
end
