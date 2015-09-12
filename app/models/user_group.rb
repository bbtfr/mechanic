class UserGroup < ActiveRecord::Base
  belongs_to :user
  has_many :users
  has_many :orders, through: :users

  has_many :mechanics, through: :users, source: :mechanic
  has_many :mechanic_orders, through: :mechanics, source: :orders

  validates_presence_of :nickname

  scope :confirmeds, -> { where(confirmed: true) }
  scope :unconfirmeds, -> { where.not(confirmed: true) }

  def confirm!
    update_attribute(:confirmed, true)
  end

  def total_cost
    orders.finisheds.sum(:price) || 0
  end

  def total_income
    mechanic_orders.finisheds.sum(:price) || 0
  end

  def total_turnover
    total_cost + total_income
  end

  def total_commission
    (total_cost * 0.05 * 0.3 + total_income * 0.05 * 0.3).round(2)
  end

  def orders_count
    orders.finisheds.count + mechanic_orders.finisheds.count
  end

  def weixin_qr_code_url
    unless weixin_qr_code_ticket
      ticket = Weixin.create_qr_limit_str_scene(scene_str: "user_group#{id}").result["ticket"]
      if ticket
        update_attribute(:weixin_qr_code_ticket, ticket)
      else
        return nil
      end
    end

    Weixin.qr_code_url(weixin_qr_code_ticket)
  end

end
