require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  let(:user) { create(:user) }

  describe "POST create" do
    def post_create
      post :create, params: { email: user[:email] }
    end

    it 'does not call #authenticate' do
      expect(controller).to_not receive(:authenticate)
      post_create
    end

    it 'finds the user' do
      expect(User).to receive(:find_by).with(email: user[:email]).and_return(user)
      post_create
    end

    it 'generates a new password reset token' do
      expect{ post_create; user.reload }.to change{ user[:password_reset_token] }
    end

    it 'sends a password reset email' do
      expect{ post_create }.to change(ActionMailer::Base.deliveries, :size)
    end
  end

  describe "PATCH update" do
    def patch_update
      patch :update, params: { id: user.password_reset_token, update: { password: "newpassword", password_confirmation: "newpassword" } }
    end

    before { user.generate_password_reset_token }

    context "with a valid reset token" do
      it 'finds the user by the reset token' do
        expect(User).to receive(:find_by).with(password_reset_token: user.password_reset_token)
        patch_update
      end

      context "when a user is found" do
        it 'calls #update_params to get the parameters' do
          allow(User).to receive(:find_by).and_return user
          allow(user).to receive(:update_attributes)
          expect(controller).to receive(:update_params).at_least(:once)
          patch_update
        end

        it 'calls update attributes on the user' do
          allow(User).to receive(:find_by).and_return(user)
          expect(user).to receive(:update_attributes)
          patch_update
        end

        it 'passes the update params to update attributes' do
          parameters = ActionController::Parameters.new({update: { password: "newpassword", password_confirmation: "newpassword" }}).require(:update).permit(:password, :password_confirmation)
          allow(User).to receive(:find_by).and_return(user)
          expect(user).to receive(:update_attributes).with(parameters)
          patch_update
        end

        it 'changes the user\'s password' do
          expect { patch_update; user.reload }.to change{ user.password_digest }
        end

        it 'deletes the password reset token' do
          expect(user.password_reset_token).to_not be nil
          patch_update
          user.reload
          expect(user.password_reset_token).to be nil
        end
      end
    end
  end
end
