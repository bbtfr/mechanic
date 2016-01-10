class SendCreateOrderMessageJob < ActiveJob::Base
  queue_as :default

  def perform(order)
    city = City.find(order.city_cd)

    users = User.mechanics
    users = users.location_scope(city)
    users = users.skill_scope(order.skill)
    users.load

    Rails.logger.info "Send order##{order.id} template message to #{users.size} users, skill = #{order.skill}, city = #{order.city}"
    users.each do |user|
      # Rails.logger.info "Send order##{order.id} template message to user##{user.id}"
      response = Weixin.send_create_order_message(user, order)
      if response && response.code == 0
        order.mechanic_sent_count += 1
        order.save
      end
    end
  end
end
