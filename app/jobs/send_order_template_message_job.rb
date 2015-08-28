class SendOrderTemplateMessageJob < ActiveJob::Base
  queue_as :default

  def perform(order)
    User.where(is_mechanic: true).each do |user|
      Rails.logger.info "Send order##{order.id} template message to user##{user.id}"
      response = Weixin.send_order_template_message user, order
      if response.code == 0
        order.mechanic_sent_count += 1
        order.save
      else
        Rails.logger.error response.inspect
      end
    end
  end
end
