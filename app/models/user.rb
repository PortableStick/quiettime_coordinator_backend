class User < ApplicationRecord
  has_secure_password
  validates :password_confirmation, presence: true, length: { minimum: 8 }, on: :create
  validates :email, uniqueness: true
end
