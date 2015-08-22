class SendOrderTemplateMessageJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Weixin.send_order_template_message
  end
end
