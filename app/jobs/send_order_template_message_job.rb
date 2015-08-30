class SendOrderTemplateMessageJob < ActiveJob::Base
  queue_as :default

  def perform(order)
    users = User.where(is_mechanic: true).load
    Rails.logger.info "Send order##{order.id} template message to #{users.size} users"
    users.each do |user|
      Rails.logger.info "Send order##{order.id} template message to user##{user.id}"
      response = Weixin.send_order_template_message user, order
      if response && response.code == 0
        order.mechanic_sent_count += 1
        order.save
      end
    end
  end
end
