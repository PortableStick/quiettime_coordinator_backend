FactoryGirl.define do
  factory :user do
    sequence(:username) { |i| "weedman_420_#{i}"}
    sequence(:email) { |i| "a#{i}@b.com" }
    password "password"
    password_confirmation "password"
    plans ["coffee-project-new-york-new-york", "another_great_place"]
  end
end
