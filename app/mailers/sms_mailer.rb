class SMSMailer < ActionSMS::Base
  def confirmation user
    @user = user
    sms to: user.mobile
  end

  def mechanic_pay_order order
    @order = order
    sms to: order.mechanic.user_mobile
  end

  def mechanic_refund_order order, original_mechanic
    @order = order
    sms to: original_mechanic.user_mobile
  end

  def contact_pay_order order
    @order = order
    template_name = "contact_pay_#{order.mobile? ? "mobile" : "merchant"}_order"
    sms to: order.contact_mobile, template_name: template_name
  end

end
