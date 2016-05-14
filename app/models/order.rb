class Order < ActiveRecord::Base
  include WeixinMediaLoader

  PendingTimeout = 10.minutes
  PayingTimeout = 60.minutes
  ConfirmingTimeout = 1.days

  belongs_to :user
  belongs_to :mechanic
  belongs_to :merchant
  has_one :mechanic_user, through: :mechanic, source: :user
  has_one :store, through: :merchant

  belongs_to :bid
  has_many :bids

  as_enum :skill, Skill, persistence: true
  as_enum :brand, Brand, persistence: true
  as_enum :series, Series, persistence: true

  as_enum :province, Province, persistence: true
  as_enum :city, City, persistence: true

  as_enum :state, pending: 0, paying: 1, pended: 2, canceled: 3, refunding: 4, refunded: 5,
    paid: 6, working: 7, confirming: 8, finished: 9, reviewed: 10, closed: 11
  as_enum :cancel, pending_timeout: 0, paying_timeout: 1, user_abstain: 2, user_cancel: 3
  as_enum :refund, user_cancel: 0, merchant_revoke: 1
  as_enum :pay_type, { weixin: 0, alipay: 1, skip: 2 }, prefix: true

  AVAILABLE_GREATER_THAN = 5
  scope :availables, -> { where('"orders"."state_cd" > ?', AVAILABLE_GREATER_THAN) }
  def available?
    state_cd > AVAILABLE_GREATER_THAN
  end

  SETTLED_GREATER_THAN = 8
  scope :settleds, -> { where('"orders"."state_cd" > ?', SETTLED_GREATER_THAN) }
  def settled?
    state_cd > SETTLED_GREATER_THAN
  end

  scope :assigneds, -> { paids.where.not(mechanic_id: nil) }
  scope :unassigneds, -> { paids.where(mechanic_id: nil) }

  scope :hostings, -> { where(hosting: true) }

  def mobile?
    !merchant_id
  end

  def merchant?
    !!merchant_id
  end

  scope :state_scope, -> (state) { where(state_cd: states.value(state)) }

  has_attached_file :mechanic_attach_1, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :mechanic_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :mechanic_attach_2, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :mechanic_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :user_attach_1, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :user_attach_1, :content_type => /\Aimage\/.*\z/
  has_attached_file :user_attach_2, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :user_attach_1, :content_type => /\Aimage\/.*\z/

  weixin_media_loaders :mechanic_attach_1, :mechanic_attach_2, :user_attach_1, :user_attach_2

  validates_numericality_of :quoted_price, greater_than_or_equal_to: 0
  validates_numericality_of :quoted_price, greater_than_or_equal_to: 1, if: :mobile?
  validates_presence_of :skill_cd, :brand_cd, :series_cd, :quoted_price
  validates_presence_of :contact_mobile, if: :merchant?
  validates_format_of :contact_mobile, with: /\A\d{11}\z/, if: :merchant?
  validate :validate_location, on: :create
  validate :validate_procedure_price, on: :update

  before_validation :ensure_contact_mobile_format
  def ensure_contact_mobile_format
    self.contact_mobile.strip! if contact_mobile
  end

  cache_method :user, :available_orders_count
  cache_method :mechanic, :available_orders_count
  cache_method :mechanic, :revoke_orders_count
  cache_method :mechanic, :professionality_average
  cache_method :mechanic, :timeliness_average

  cache_column :user, :nickname
  cache_column :user, :mobile

  cache_column :mechanic_user, :nickname, cache_column: :mechanic_nickname
  cache_column :mechanic_user, :mobile, cache_column: :mechanic_mobile
  cache_column :merchant, :nickname
  cache_column :merchant, :mobile
  cache_column :store, :nickname
  cache_column :store, :hotline

  def hosting?
    hosting
  end

  def appointing?
    appointing
  end

  attr_accessor :custom_location
  def custom_location_present?
    ["1", 1, true].include?(custom_location) && province_cd.present? && city_cd.present?
  end

  def validate_location
    return if custom_location_present?

    if lbs_id.present?
      location = LBS.find(lbs_id)

      case location
      when District
        city = location.parent
      when City
        city = location
      when Province
        raise ArgumentError
      end

      province = city.parent

      self.province_cd = province.id
      self.city_cd = city.id
    else
      result = LBS.geocoder(address)

      province_name = result["result"]["address_components"]["province"]
      city_name = result["result"]["address_components"]["city"]

      province = Province.where(fullname: province_name).first!
      city = province.cities.where(fullname: city_name).first!

      self.lbs_id = city.lbs_id
      self.province_cd = province.id
      self.city_cd = city.id
    end
  rescue
    errors.add(:address, "无法定位，请打开GPS定位或输入自定义技师用人信息发送范围")
  end

  def validate_procedure_price
    if procedure_price > quoted_price
      errors.add(:procedure_price, "应低于订单标价")
    end
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
    else
      self.appointing = true if self.mechanic_id
    end
  end

  after_create do
    unless appointing?
      SendCreateOrderMessageJob.set(wait: 1.second).perform_later(self)
      if hosting?
        pick!
      else
        pending!
      end
    end
  end

  def pend!
    return false unless paying?
    update_attribute(:state, Order.states[:pended])
    true
  end

  def pending!
    UpdateOrderStateJob.set(wait: PendingTimeout).perform_later(self)
    true
  end

  def pick! target = nil
    return false unless pending?
    update_attribute(:state, Order.states[:paying])
    UpdateOrderStateJob.set(wait: PayingTimeout).perform_later(self)

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

  def contact
    contact_nickname.presence
  end

  def settings
    FallbackScopedSettings.for_things self, self.store
  end

  def price
    quoted_price + markup_price
  end

  def commission
    @commission ||= ((quoted_price - procedure_price) * (mobile? ? settings.mobile_commission_percent.to_f :
      settings.commission_percent.to_f) / 100).round(2)
  end

  def mechanic_income
    price - commission - procedure_price
  end

  def client_commission
    (commission * settings.client_commission_percent.to_f / 100).round(2)
  end

  def mechanic_commission
    (commission * settings.mechanic_commission_percent.to_f / 100).round(2)
  end

  def title
    "汽车堂#{skill}订单"
  end

  def mobile
    contact_mobile || user.mobile
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

  def out_refund_no force = false
    update_timestamp :refunded_at, true, force
    "#{refunded_at.strftime("%Y%m%d")}#{"%06d" % id}"
  end

end
