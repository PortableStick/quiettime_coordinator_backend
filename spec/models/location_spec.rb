require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:loc) { create(:location) }

  describe "#increment_attendence" do
    it 'should increment attendence count by 1' do
      expect{ loc.increment_attendence }.to change{ loc.attending }.by(1)
    end

    it 'should save the incremented attendence' do
      expect{ loc.increment_attendence }.to change{ loc.attending }.by(1)
      new_attending = Location.find_by(coords: loc.coords).attending
      expect(new_attending).to eq(loc.attending)
    end
  end

  describe '#decrement_attendence' do
    it 'should decrement attendence count by 1' do
      expect{ loc.decrement_attendence }.to change{ loc.attending }.by(-1)
    end

    it 'should save the decremented attendence' do
      expect{ loc.decrement_attendence }.to change{ loc.attending }.by(-1)
      new_attending = Location.find_by(coords: loc.coords).attending
      expect(new_attending).to eq(loc.attending)
    end
  end
end
