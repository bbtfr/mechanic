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

  as_enum :state, { pending: 0, canceled: 1, refunded: 2, paid: 3, working: 4,
    confirming: 5, finished: 6, reviewed: 7 }
  as_enum :cancel, { pending_timeout: 0, paying_timeout: 1, user_cancel: 2, refunded: 3 }

  scope :availables, -> { where('"orders"."state_cd" > 2') }

  def available?
    state_cd > 2
  end

  alias_attribute :contact, :contact_nickname

  has_attached_file :mechanic_attach_1, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :mechanic_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :mechanic_attach_2, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :mechanic_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :user_attach_1, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :user_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :user_attach_2, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :user_attach_1, :content_type => /\Aimage\/.*\Z/

  validates_numericality_of :quoted_price, greater_than_or_equal_to: 1
  validates_presence_of :skill, :brand_id, :series_id, :quoted_price
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
      if pending?
        if mechanic_id
          if Time.now - updated_at >= PayingTimeout
            cancel! :paying_timeout
          end
        else
          if Time.now - created_at >= PendingTimeout
            cancel! :pending_timeout
          end
        end

      elsif confirming? && Time.now - updated_at > ConfirmingTimeout
        confirm!
      end
    end
  end

  after_create do
    SendCreateOrderMessageJob.perform_later(self)
    UpdateOrderStateJob.set(wait: PendingTimeout).perform_later(self)
  end

  def pick! bid
    return false if canceled?
    UpdateOrderStateJob.set(wait: PayingTimeout).perform_later(self)
    self.bid_id = bid.id
    self.mechanic_id = bid.mechanic_id
    self.price = quoted_price + bid.markup_price
    save
  end

  def cancel! reason = :user_cancel
    return false unless pending?
    update_attribute(:cancel, Order.cancels[reason])
    update_attribute(:state, Order.states[:canceled])
  end

  def pay!
    return false unless pending? || canceled?
    update_attribute(:state, Order.states[:paid])
    Weixin.send_paid_order_message self
  rescue => error
    Rails.logger.error "#{error.class}: #{error.message} from Order#pay!"
  end

  def refund!
    return false unless paid?
    update_attribute(:cancel, Order.cancels[:refunded])
    update_attribute(:state, Order.states[:refunded])
  end

  def work!
    return false unless paid?
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
    user.balance += price
    user.save
    update_attribute(:state, Order.states[:finished])
  end

  def review!
    update_attribute(:state, Order.states[:reviewed])
  end

  def title
    "#{mechanic.user.nickname} 为您 #{skill.name}"
  end

  def mobile
    contact_mobile || user.mobile
  end

  def trade_no
    "order#{id}created_at#{created_at.to_i}"
  end

  def refund_no
    "order#{id}created_at#{created_at.to_i}refund"
  end

end
