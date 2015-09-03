class SendOrderTemplateMessageJob < ActiveJob::Base
  queue_as :default

  def perform(order)
    users = User.where(is_mechanic: true)

    lbs_id = order.lbs_id
    location = District.where(lbs_id: lbs_id).first ||
      City.where(lbs_id: lbs_id).first ||
      Province.where(lbs_id: lbs_id).first
    users = users.where(location.class.name.foreign_key => location.id) if location

    users.joins(mechanic: :skills).where("skills.id" => order.skill_id)
    users.load

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
