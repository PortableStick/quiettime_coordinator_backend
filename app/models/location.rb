class Location < ApplicationRecord
  def increment_attendence
    increment(:attending, 1)
    save
  end

  def decrement_attendence
    decrement(:attending, 1)
    save
  end
end
