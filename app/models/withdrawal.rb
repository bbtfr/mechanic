class Withdrawal < ActiveRecord::Base
  belongs_to :user

  as_enum :state, pending: 0, canceled: 1, paid: 2

  after_create do
    user.balance -= amount
    user.save
  end

  validates_numericality_of :amount, greater_than: 1
  validates_presence_of :amount
  validate :validate_amount

  def validate_amount
    errors.add(:base, "账户余额不足") if amount && amount > user.balance
  end

  def pay!
    return false unless pending?
    update_attribute(:state, Withdrawal.states[:paid])
  end

  def cancel!
    return false unless pending?
    user.balance += amount
    user.save
    update_attribute(:state, Withdrawal.states[:canceled])
  end

  def title
    "#{user.nickname} 申请提现 #{amount} 元"
  end

  def out_trade_no
    "withdrawal#{id}created_at#{created_at.to_i}"
  end
end
