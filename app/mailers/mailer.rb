class Mailer < ActionMailer::Base

  def password_reset(user)
    @user = user

    mail(:to => user.email, :subject => "Razor Password reset")
  end

end