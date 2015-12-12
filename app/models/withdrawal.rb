class Withdrawal < ActiveRecord::Base
  belongs_to :user

  as_enum :state, pending: 0, canceled: 1, paid: 2

  after_create do
    user.increase_balance!(-amount, "申请提现", self)
  end

  validates_numericality_of :amount, greater_than_or_equal_to: 1
  validates_presence_of :amount
  validate :validate_amount

  def validate_amount
    errors.add(:base, "账户余额不足") if amount && amount > user.balance
  end

  def pay!
    return false unless pending?
    update_attribute(:paid_at, Time.now)
    update_attribute(:state, Withdrawal.states[:paid])
  end

  def cancel!
    return false unless pending?
    user.increase_balance!(amount, "取消提现", self)
    update_attribute(:state, Withdrawal.states[:canceled])
  end

  def title
    "#{user.nickname} 申请提现 #{amount} 元"
  end

  def out_trade_no
    "#{created_at.strftime("%Y%m%d")}#{"%06d" % id}"
  end
end
