class SMSMailer < ActionSMS::Base
  def confirmation user
    @user = user
    sms to: user.mobile
  end

  def mechanic_notification order
    @order = order
    sms to: order.mechanic.user_mobile
  end

  def contact_notification order
    @order = order
    template_name = "contact_notification_#{order.mobile? ? "mobile" : "merchant"}"
    sms to: order.contact_mobile, template_name: template_name
  end

end
