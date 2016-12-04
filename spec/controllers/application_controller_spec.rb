require 'rails_helper'
require 'jwt'

RSpec.describe ApplicationController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }
  let(:bad_token) { JWT.encode({ user: (user.id * 47) }, Rails.application.secrets.secret_key_base, 'HS256') }

  context 'with valid credentials' do
    before(:each) do
      allow(controller).to receive(:token).and_return(token)
      allow(controller).to receive(:auth_present?).and_return(true)
    end

    describe '#current_user' do
      it 'returns the current user' do
        expect(controller.send(:current_user)).to eq(user)
      end
    end

    describe '#logged_in?' do
      it 'returns true' do
        expect(controller.send(:logged_in?)).to be true
      end
    end

    describe '#authenticate' do
      it 'returns nil' do
        expect(controller.send(:authenticate)).to be nil
      end
    end
  end

  context 'with invalid credentials' do
    before(:each) do
      allow(controller).to receive(:token).and_return(bad_token)
      allow(controller).to receive(:auth_present?).and_return(true)
    end

    describe '#current_user' do
      it 'returns an error with status 404' do
        expect(controller).to receive(:render).with(json: { message: "User not found" }, status:404)
        controller.send(:current_user)
      end
    end

    describe '#logged_in?' do
      it 'returns false' do
        allow(controller).to receive(:current_user).and_return(nil)
        expect(controller.send(:logged_in?)).to be false
      end
    end

    describe '#authenticate' do
      before(:each) do
        allow(controller).to receive(:logged_in?).and_return(false)
      end

      it 'it renders an error with status 403' do
        expect(controller).to receive(:render).with(json: { message: "Unauthorized access" }, status: 403)
        controller.send(:authenticate)
      end
    end
  end

  context 'auth token is not present' do
    before(:each) do
      allow(controller).to receive(:auth_present?).and_return(false)
    end

    describe '#current_user' do
      it 'returns nil' do
        expect(controller.send(:current_user)).to be_nil
      end
    end
  end
end