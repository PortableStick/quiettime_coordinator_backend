class NotifierMailer < ApplicationMailer
  default_url_options[:host] = "localhost:3000"

  def password_reset(user)
    @user = user
    mail(to: "#{user[:username]} <#{user[:email]}>", subject: "Reset your password")
  end

  def confirm_user(user)
    @user = user
    mail(to: "#{user[:username]} <#{user[:email]}", subject: "Confirm your account")
  end
end
