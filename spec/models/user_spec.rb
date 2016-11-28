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

  context "#downcase email" do
    it 'changes the email to lower case' do
      user = User.new(valid_attributes.merge(email: "A@B.COM"))
      expect { user.downcase_email }.to change { user.email }
        .from("A@B.COM")
        .to("a@b.com")
    end

    it 'downcases the email before saving' do
      user = User.new(valid_attributes.merge(email: "A@B.COM"))
      expect(user.save).to be true
      expect(user.email).to eq('a@b.com')
    end
  end

  context 'plans' do
    let(:user) { build(:user) }

    it 'has an array of plans' do
      expect(user.plans).to be_a(Array)
    end

    context '#add_location_to_plans' do
      it 'should add the given location to user\'s plans' do
        user.add_location_to_plans("Disneyland")
        expect(user.plans).to include("Disneyland")
      end
    end

    context '#remove_location_from_plans' do
      it 'should remove the given location from the user\'s plans' do
        user.add_location_to_plans("Disneyland")
        expect(user.plans).to include("Disneyland")
        user.remove_location_from_plans("Disneyland")
        expect(user.plans).not_to include("Disneyland")
      end
    end
  end
end
