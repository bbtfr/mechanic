class UserGroup < ActiveRecord::Base
  belongs_to :user
  has_many :users
  has_many :orders, through: :users

  validates_presence_of :nickname

  scope :confirmeds, proc { where(confirmed: true) }
  scope :unconfirmeds, proc { where.not(confirmed: true) }

  def confirm!
    user.update_attribute(:user_group_id, id)
    update_attribute(:confirmed, true)
  end

  def total_cost
    orders.available.sum(:price) || 0
  end

  def orders_count
    orders.available.count || 0
  end

  def weixin_qr_code_url
    unless weixin_qr_code_ticket
      ticket = Weixin.create_qr_limit_str_scene(scene_str: "user_groups#{id}").result["ticket"]
      if ticket
        update_attribute(:weixin_qr_code_ticket, ticket)
      else
        return nil
      end
    end

    Weixin.qr_code_url(weixin_qr_code_ticket)
  end

end
