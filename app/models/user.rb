class User < ApplicationRecord
  has_secure_password
  validates :password_confirmation, presence: true, length: { minimum: 8 }, on: :create
  validates :email, uniqueness: true

  before_save :downcase_email

  def downcase_email
    self.email = email.downcase
  end

  def add_location_to_plans(location)
    return false if plans.include? location
    plans_will_change!
    update_attribute :plans, plans.push(location)
  end

  def remove_location_from_plans(location)
    return false unless plans.include? location
    plans_will_change!
    update_attribute :plans, plans - [location]
  end
end
