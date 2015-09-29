class Order < ActiveRecord::Base
  PendingTimeout = 60.minutes
  PayingTimeout = 60.minutes
  ConfirmingTimeout = 5.days

  belongs_to :skill
  belongs_to :brand
  belongs_to :series

  belongs_to :user
  belongs_to :mechanic
  belongs_to :merchant

  belongs_to :bid
  has_many :bids

  as_enum :state, pending: 0, paying: 1, canceled: 2, refunded: 3, paid: 4, working: 5,
    confirming: 6, finished: 7, reviewed: 8
  as_enum :cancel, pending_timeout: 0, paying_timeout: 1, user_abstain: 2, user_cancel: 3
  as_enum :pay_type, { weixin: 0, alipay: 1 }, prefix: true

  AVAILABLE_GREATER_THAN = 3
  scope :availables, -> { where('"orders"."state_cd" > ?', AVAILABLE_GREATER_THAN) }
  def available?
    state_cd > AVAILABLE_GREATER_THAN
  end

  has_attached_file :mechanic_attach_1, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :mechanic_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :mechanic_attach_2, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :mechanic_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :user_attach_1, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :user_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :user_attach_2, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :user_attach_1, :content_type => /\Aimage\/.*\Z/

  validates_numericality_of :quoted_price, greater_than_or_equal_to: 1
  validates_presence_of :skill_id, :brand_id, :series_id, :quoted_price
  validates_presence_of :contact_mobile, if: :merchant_id
  validates_format_of :contact_mobile, with: /\d{11}/, if: :merchant_id
  validate :validate_lbs_id, on: :create

  delegate :nickname, :mobile, to: :user, prefix: true
  delegate :nickname, :mobile, to: :merchant, prefix: true

  def validate_lbs_id
    return if lbs_id.present?
    result = LBS.geocoder address
    district_name = result["result"]["address_components"]["district"]
    district = District.where(name: district_name).first
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
    SendCreateOrderMessageJob.perform_later(self)
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
    Weixin.send_paid_order_message self
  rescue => error
    Rails.logger.error "#{error.class}: #{error.message} from Order#pay!"
  end

  def refund!
    return false unless paid?
    update_attribute(:state, Order.states[:refunded])
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
    user = mechanic.user
    user.increase_balance!(price - commission)

    client_chief = user.user_group.user rescue nil
    client_chief.increase_balance!(client_commission) if client_chief

    mechanic_chief = mechanic.user.user_group.user rescue nil
    mechanic_chief.increase_balance!(mechanic_commission) if mechanic_chief

    update_attribute(:state, Order.states[:finished])
  end

  def review!
    update_attribute(:state, Order.states[:reviewed])
  end

  def contact
    contact_nickname.presence
  end

  def commission
    @commission ||= (price * Setting.commission_percent.to_f / 100).round(2)
  end

  def client_commission
    (commission * Setting.client_commission_percent.to_f / 100).round(2)
  end

  def mechanic_commission
    (commission * Setting.mechanic_commission_percent.to_f / 100).round(2)
  end

  def title
    "#{mechanic.user.nickname} 为您 #{skill.name}"
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
