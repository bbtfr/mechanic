class Recharge < ApplicationRecord
  AVAILABLE_VALUES = [ 50, 100, 200, 500, 1000 ]

  belongs_to :user
  belongs_to :store

  as_enum :state, pending: 0, canceled: 1, paid: 2
  as_enum :pay_type, { weixin: 0, alipay: 1, skip: 2 }, prefix: true

  validates_numericality_of :amount, greater_than_or_equal_to: 1
  validates_inclusion_of :amount, in: AVAILABLE_VALUES
  validates_presence_of :amount

  def pay! pay_type = :alipay, trade_no = nil
    return false unless pending?
    update_attribute(:pay_type, Recharge.pay_types[pay_type])
    update_attribute(:trade_no, trade_no) if trade_no
    store.increase_balance!(amount, "用户充值", self)
    update_attribute(:state, Recharge.states[:paid])
  rescue => error
    Rails.logger.error "#{error.class}: #{error.message} from Recharge#pay!"
  end

  def cancel!
    return false unless pending?
    update_attribute(:state, Recharge.states[:canceled])
  end

  def title
    "#{user.nickname} 为 #{store.nickname} 充值 #{amount} 元"
  end

  def update_timestamp column, update, force
    if force || (!send(column) && update)
      update_attribute(column, Time.now)
    end
  end

  def out_trade_no force = false
    update_timestamp :paid_at, true, force
    "#{paid_at.strftime("%Y%m%d")}#{"%06d" % id}"
  end
end
