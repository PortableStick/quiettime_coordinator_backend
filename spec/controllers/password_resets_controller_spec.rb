require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  describe "POST create" do
    context "with a valid user and email" do
      let(:user) { create(:user) }

      def post_create
        post :create, params: { email: user[:email] }
      end

      it 'does not authenticate the user' do
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

    context 'with no valid user' do
      def bad_create
        post :create, params: { email: "dog" }
      end
    end
  end
end
