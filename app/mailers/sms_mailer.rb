class SMSMailer < ActionSMS::Base
  def confirmation user
    @user = user
    sms to: user.mobile
  end

end
