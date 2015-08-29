class UpdateOrderStateJob < ActiveJob::Base
  queue_as :default

  def perform(order)
    order.save
  end
end
