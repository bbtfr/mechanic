class UpdateOrderStateJob < ActiveJob::Base
  queue_as :default

  def perform(order)
    if order
      order.save
    else
      Rails.logger.error "Empty Order Model: #{self.inspect}"
    end
  end
end
