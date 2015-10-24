class UserGroup < ActiveRecord::Base
  belongs_to :user
  has_many :users
  has_many :orders, through: :users

  has_many :mechanics, through: :users, source: :mechanic
  has_many :mechanic_orders, through: :mechanics, source: :orders

  validates_presence_of :nickname

  delegate :nickname, :role, to: :user, prefix: true

  scope :confirmeds, -> { where(confirmed: true) }
  scope :unconfirmeds, -> { where.not(confirmed: true) }

  def increase_total_commission! amount
    increment!(:total_commission, amount)
  end

  def confirm!
    update_attribute(:confirmed, true)
  end

  def settled_orders_count
    orders.settleds.count + mechanic_orders.settleds.count
  end

  def users_count
    users.count
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
