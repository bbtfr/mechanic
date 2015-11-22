class SendCreateOrderMessageJob < ActiveJob::Base
  queue_as :default

  def perform(order)
    users = User.mechanics

    location = LBS.find(order.lbs_id)
    users = users.location_scope(location)

    users = users.skill_scope(order.skill)
    users.load

    Rails.logger.info "Send order##{order.id} template message to #{users.size} users, skill_cd = #{order.skill_cd}, lbs_id = #{order.lbs_id} (#{location.try :name})"
    users.each do |user|
      Rails.logger.info "Send order##{order.id} template message to user##{user.id}"
      response = Weixin.send_create_order_message user, order rescue nil
      if response && response.code == 0
        order.mechanic_sent_count += 1
        order.save
      end
    end
  end
end
