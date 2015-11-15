class Order < ActiveRecord::Base
  PendingTimeout = 10.minutes
  PayingTimeout = 60.minutes
  ConfirmingTimeout = 1.days

  belongs_to :user
  belongs_to :mechanic
  belongs_to :merchant

  belongs_to :bid
  has_many :bids

  as_enum :skill, Skill, persistence: true
  as_enum :brand, Brand, persistence: true
  as_enum :series, Series, persistence: true

  as_enum :state, pending: 0, paying: 1, canceled: 2, refunding: 3, refunded: 4, paid: 5, working: 6,
    confirming: 7, finished: 8, reviewed: 9
  as_enum :cancel, pending_timeout: 0, paying_timeout: 1, user_abstain: 2, user_cancel: 3
  as_enum :refund, user_cancel: 0, merchant_revoke: 1
  as_enum :pay_type, { weixin: 0, alipay: 1 }, prefix: true

  AVAILABLE_GREATER_THAN = 4
  scope :availables, -> { where('"orders"."state_cd" > ?', AVAILABLE_GREATER_THAN) }
  def available?
    state_cd > AVAILABLE_GREATER_THAN
  end

  SETTLED_GREATER_THAN = 7
  scope :settleds, -> { where('"orders"."state_cd" > ?', SETTLED_GREATER_THAN) }
  def settled?
    state_cd > SETTLED_GREATER_THAN
  end

  def mobile?
    !merchant_id
  end

  scope :state_scope, -> (state) { where(state_cd: states.value(state)) }

  has_attached_file :mechanic_attach_1, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :mechanic_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :mechanic_attach_2, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :mechanic_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :user_attach_1, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :user_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :user_attach_2, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :user_attach_1, :content_type => /\Aimage\/.*\Z/

  validates_numericality_of :quoted_price, greater_than_or_equal_to: 1
  validates_presence_of :skill_cd, :brand_cd, :series_cd, :quoted_price
  validates_presence_of :contact_mobile, if: :merchant_id
  validates_format_of :contact_mobile, with: /\d{11}/, if: :merchant_id
  validate :validate_lbs_id, on: :create

  delegate :nickname, :mobile, to: :user, prefix: true
  delegate :nickname, :mobile, to: :merchant, prefix: true

  def validate_lbs_id
    return if lbs_id.present?
    result = LBS.geocoder address

    province_name = result["result"]["address_components"]["province"]
    city_name = result["result"]["address_components"]["city"]
    district_name = result["result"]["address_components"]["district"]

    district = District.joins(city: [:province]).where(
      provinces: { fullname: province_name },
      cities: { fullname: city_name },
      districts: { fullname: district_name }
    ).first!

    self.lbs_id = district.lbs_id
  rescue
    errors.add(:address, "无法定位，请打开GPS定位或输入更详细的地址") unless lbs_id.present?
  end

  after_initialize do
    if persisted?
      if pending? && Time.now - created_at >= PendingTimeout
        if mechanic_sent_count > 0
          cancel! :pending_timeout
        else
          cancel! :user_abstain
        end
      elsif paying? && Time.now - updated_at >= PayingTimeout
        cancel! :paying_timeout
      elsif confirming? && Time.now - updated_at > ConfirmingTimeout
        confirm!
      end
    end
  end

  after_create do
    SendCreateOrderMessageJob.set(wait: 1.second).perform_later(self)
    if mechanic_id
      pick!
    else
      pend!
    end
  end

  def pend!
    UpdateOrderStateJob.set(wait: PendingTimeout).perform_later(self)
  end

  def pick! bid = nil
    return false unless pending?
    update_attribute(:state, Order.states[:paying])
    UpdateOrderStateJob.set(wait: PayingTimeout).perform_later(self)

    if bid
      self.bid_id = bid.id
      self.mechanic_id = bid.mechanic_id
      self.markup_price = bid.markup_price
    end

    self.price = quoted_price + markup_price
    save(validate: false)
  end

  def cancel! reason = :user_cancel
    return false unless pending? || paying?
    update_attribute(:cancel, Order.cancels[reason])
    update_attribute(:state, Order.states[:canceled])
  end

  def pay! pay_type = :weixin, trade_no = nil
    return false unless paying? || canceled?
    update_attribute(:pay_type, Order.pay_types[pay_type])
    update_attribute(:trade_no, trade_no) if trade_no
    update_attribute(:state, Order.states[:paid])
    user.increase_total_cost!(price)
    Weixin.send_paid_order_message self
  rescue => error
    Rails.logger.error "#{error.class}: #{error.message} from Order#pay!"
  end

  def refunding! reason = :user_cancel
    return false unless paid? || working?
    update_attribute(:refund, Order.refunds[reason])
    update_attribute(:state, Order.states[:refunding])
  end

  def refund! reason = :user_cancel
    return false unless refunding? || paid? || working?
    update_attribute(:refund, Order.refunds[reason]) unless refunding?
    update_attribute(:state, Order.states[:refunded])
    user.increase_total_cost!(-price)
  end

  def work!
    return false unless paid?
    update_attribute(:start_working_at, Time.now)
    update_attribute(:state, Order.states[:working])
  end

  def finish!
    return false unless working?
    update_attribute(:state, Order.states[:confirming])
    UpdateOrderStateJob.set(wait: ConfirmingTimeout).perform_later(self)
    Weixin.send_confirm_order_message self
  rescue => error
    Rails.logger.error "#{error.class}: #{error.message} from Order#finish!"
  end

  def confirm!
    return false unless confirming?

    mechanic.user.increase_balance!(mechanic_income)
    mechanic.increase_total_income!(mechanic_income)

    if client_user_group = user.user_group
      client_user_group.user.increase_balance!(client_commission)
      client_user_group.increase_total_commission!(client_commission)
    end

    if mechanic_user_group = mechanic.user_group
      mechanic_user_group.user.increase_balance!(mechanic_commission)
      mechanic_user_group.increase_total_commission!(mechanic_commission)
    end

    update_attribute(:state, Order.states[:finished])
  end

  def rework!
    return false unless confirming?
    update_attribute(:state, Order.states[:paid])
    Weixin.send_rework_order_message self
  rescue => error
    Rails.logger.error "#{error.class}: #{error.message} from Order#finish!"
  end

  def review!
    update_attribute(:state, Order.states[:reviewed])
  end

  def contact
    contact_nickname.presence
  end

  def commission
    @commission ||= (price * (mobile? ? Setting.mobile_commission_percent.to_f :
      Setting.commission_percent.to_f) / 100).round(2)
  end

  def mechanic_income
    price - commission
  end

  def client_commission
    (commission * Setting.client_commission_percent.to_f / 100).round(2)
  end

  def mechanic_commission
    (commission * Setting.mechanic_commission_percent.to_f / 100).round(2)
  end

  def title
    "#{mechanic.user.nickname} 为您 #{skill}"
  end

  def mobile
    contact_mobile || user.mobile
  end

  def out_trade_no update_timestamp = true
    update_attribute(:paid_at, Time.now) if update_timestamp
    "#{paid_at.strftime("%Y%m%d")}#{"%06d" % id}"
  end

  def out_refund_no update_timestamp = true
    update_attribute(:refunded_at, Time.now) if update_timestamp
    "#{refunded_at.strftime("%Y%m%d")}#{"%06d" % id}"
  end

end
