module Order::State
  extend ActiveSupport::Concern

  AVAILABLE_GREATER_THAN = 5
  SETTLED_GREATER_THAN = 8

  included do
    as_enum :state, pending: 0, paying: 1, pended: 2, canceled: 3, refunding: 4, refunded: 5,
      paid: 6, working: 7, confirming: 8, finished: 9, reviewed: 10, closed: 11
    as_enum :cancel, pending_timeout: 0, paying_timeout: 1, user_abstain: 2, user_cancel: 3
    as_enum :refund, user_cancel: 0, merchant_revoke: 1

    as_enum :pay_type, { weixin: 0, alipay: 1, skip: 2 }, prefix: true

    scope :availables, -> { where('"orders"."state_cd" > ?', AVAILABLE_GREATER_THAN) }
    def available?
      state_cd > AVAILABLE_GREATER_THAN
    end

    scope :settleds, -> { where('"orders"."state_cd" > ?', SETTLED_GREATER_THAN) }
    def settled?
      state_cd > SETTLED_GREATER_THAN
    end

    scope :state_scope, -> (state) { where(state_cd: states.value(state)) }

  end

  def pend!
    return false unless paying?
    update_attribute(:state, Order.states[:pended])
    true
  end

  def pending!
    SendCreateOrderMessageJob.set(wait: 1.second).perform_later(self)
    UpdateOrderStateJob.set(wait: PendingTimeout).perform_later(self)
    true
  end

  def pick! target = nil
    return false unless pending?
    update_attribute(:state, Order.states[:paying])
    UpdateOrderStateJob.set(wait: PayingTimeout).perform_later(self)

    # target could be a bid or a mechanic
    case target
    when Bid
      self.bid_id = target.id
      self.mechanic_id = target.mechanic_id
      self.markup_price = target.markup_price
    when Mechanic
      self.mechanic_id = target.id
    end

    pay! :skip if price.zero?
    save(validate: false)
    true
  end

  def repick! mechanic
    # Only available and non-setted orders can repick mechanic
    return false unless state_cd > AVAILABLE_GREATER_THAN && state_cd <= SETTLED_GREATER_THAN
    update_attribute(:state, Order.states[:paid])
    update_attribute(:mechanic, mechanic)
    Weixin.send_paid_order_message(self)
    SMSMailer.mechanic_notification(self).deliver
    SMSMailer.contact_notification(self).deliver if contact_mobile
    true
  end

  def cancel! reason = :user_cancel
    return false unless pending? || paying? || pended?
    update_attribute(:cancel, Order.cancels[reason])
    update_attribute(:state, Order.states[:canceled])
    true
  end

  def pay! pay_type = :weixin, trade_no = nil
    return false unless paying? || pended? || canceled?
    update_attribute(:pay_type, Order.pay_types[pay_type])
    update_attribute(:trade_no, trade_no) if trade_no
    update_attribute(:state, Order.states[:paid])
    user.increase_total_cost!(price)

    if mechanic
      Weixin.send_paid_order_message(self)
      SMSMailer.mechanic_notification(self).deliver
      SMSMailer.contact_notification(self).deliver if contact_mobile
    end

    true
  rescue => error
    Rails.logger.error "#{error.class}: #{error.message} from Order#pay!"
  end

  def refunding! reason = :user_cancel
    return false unless paid? || working?
    update_attribute(:refund, Order.refunds[reason])
    update_attribute(:state, Order.states[:refunding])
    true
  end

  def refund! reason = :user_cancel
    return false unless refunding? || paid? || working? || confirming?
    update_attribute(:refund, Order.refunds[reason]) unless refunding?
    update_attribute(:state, Order.states[:refunded])
    user.increase_total_cost!(-price)
    true
  end

  def work!
    return false unless paid?
    update_attribute(:start_working_at, Time.now)
    update_attribute(:state, Order.states[:working])
    true
  end

  def finish!
    return false unless working?
    if !mobile? && !mechanic_attach_1.present?
      errors.add(:mechanic_attach_1, "网页端派单请上传车主短信照片")
      return false
    end
    update_attribute(:state, Order.states[:confirming])
    UpdateOrderStateJob.set(wait: ConfirmingTimeout).perform_later(self)
    Weixin.send_confirm_order_message self
    true
  rescue => error
    Rails.logger.error "#{error.class}: #{error.message} from Order#finish!"
  end

  def confirm!
    return false unless confirming?

    mechanic.user.increase_balance!(mechanic_income, "订单结算", self)
    mechanic.increase_total_income!(mechanic_income)

    if client_user_group = user.user_group
      client_user_group.user.increase_balance!(client_commission, "订单分红", self)
      client_user_group.increase_total_commission!(client_commission)
    end

    if mechanic_user_group = mechanic.user_group
      mechanic_user_group.user.increase_balance!(mechanic_commission, "订单分红", self)
      mechanic_user_group.increase_total_commission!(mechanic_commission)
    end

    update_attribute(:finish_working_at, Time.now)
    update_attribute(:state, Order.states[:finished])
    true
  end

  def rework!
    return false unless confirming?
    update_attribute(:state, Order.states[:working])
    Weixin.send_rework_order_message self
    true
  rescue => error
    Rails.logger.error "#{error.class}: #{error.message} from Order#rework!"
  end

  def review!
    update_attribute(:reviewed_at, Time.now)
    update_attribute(:state, Order.states[:reviewed])
    true
  end

  def close!
    return false unless reviewed?
    update_attribute(:closed_at, Time.now)
    update_attribute(:state, Order.states[:closed])
    true
  end
end
