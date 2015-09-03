class SendCreateOrderMessageJob < ActiveJob::Base
  queue_as :default

  def perform(order)
    users = User.where(is_mechanic: true).joins(mechanic: :skills)

    lbs_id = order.lbs_id
    location = District.where(lbs_id: lbs_id).first ||
      City.where(lbs_id: lbs_id).first ||
      Province.where(lbs_id: lbs_id).first
    foreign_key = "mechanics.#{location.class.name.foreign_key}"
    users = users.where(foreign_key => location.id) if location

    users = users.where("skills.id" => order.skill_id)
    users.load

    Rails.logger.info "Send order##{order.id} template message to #{users.size} users, skill_id = #{order.skill_id}, lbs_id = #{order.lbs_id} (#{location.try :name})"
    users.each do |user|
      Rails.logger.info "Send order##{order.id} template message to user##{user.id}"
      response = Weixin.send_create_order_message user, order
      if response && response.code == 0
        order.mechanic_sent_count += 1
        order.save
      end
    end
  end
end
