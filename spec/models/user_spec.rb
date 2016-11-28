require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_attributes) { { email: "a@b.com", password: "password", password_confirmation: "password" } }

  context "validations" do
    let(:user) { build(:user) }

    before do
      User.create(valid_attributes)
    end

    it 'requires a password confirmation when creating' do
      expect(user).to validate_presence_of :password_confirmation
    end

    it 'requires the password to be at least 8 characters' do
      expect(user).to validate_length_of :password
    end

    it 'is valid with valid input' do
      expect(user).to be_valid
    end

    it 'requires a unique email' do
      user.email = "a@b.com"
      expect(user).to validate_uniqueness_of :email
    end
  end
end
