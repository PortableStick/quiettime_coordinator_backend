class User < ApplicationRecord
  has_secure_password
  validates :password_confirmation, presence: true, length: { minimum: 8 }, on: :create
  validates :email, uniqueness: true

  before_save :downcase_email

  def downcase_email
    self.email = email.downcase
  end
end
