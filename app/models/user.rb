class User < ApplicationRecord
  has_secure_password
  validates :password_confirmation, presence: true, length: { minimum: 8 }, on: :create
  validates :email, presence: true, uniqueness: true
  validates :username, uniqueness: true

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

  def generate_password_reset_token
    update_attribute(:password_reset_token, SecureRandom.urlsafe_base64(48))
  end

  def clear_reset_token
    update_attribute(:password_reset_token, nil)
  end

  def confirm_user
    update_attribute(:confirmed, true)
  end

  def user_data
    { email: email, username: username, confirmed: confirmed, plans: plans, id: id }
  end
end
