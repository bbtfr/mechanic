class Order < ActiveRecord::Base
  PendingTimeout = 5.minutes
  PayingTimeout = 5.minutes
  ConfirmingTimeout = 5.minutes

  belongs_to :skill
  belongs_to :brand
  belongs_to :series

  belongs_to :user
  belongs_to :mechanic
  belongs_to :bid
  has_many :bids

  as_enum :state, pending: 0, canceled: 1, paid: 2, working: 3,
    confirming: 4, finished: 5

  scope :available, proc { where('"orders"."state_cd" > 1') }

  has_attached_file :mechanic_attach_1, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :mechanic_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :mechanic_attach_2, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :mechanic_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :user_attach_1, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :user_attach_1, :content_type => /\Aimage\/.*\Z/
  has_attached_file :user_attach_2, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :user_attach_1, :content_type => /\Aimage\/.*\Z/

  validates_presence_of :skill, :brand, :series, :quoted_price

  after_initialize do
    if persisted?
      if pending?
        if (!mechanic_id && Time.now - created_at > PendingTimeout) ||
          (mechanic_id && Time.now - updated_at > PayingTimeout)
            cancel!
        end
      elsif confirming? && Time.now - updated_at > ConfirmingTimeout
        confirm!
      end
    end
  end

  after_create do
    SendOrderTemplateMessageJob.perform_later(self)
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

  def cancel!
    return false unless pending?
    update_attribute(:state_cd, Order.states[:canceled])
  end

  def pay!
    return false unless pending?
    update_attribute(:state, Order.states[:paid])
  end

  def work!
    return false unless paid?
    update_attribute(:state, Order.states[:working])
  end

  def finish!
    return false unless working?
    update_attribute(:state, Order.states[:confirming])
    UpdateOrderStateJob.set(wait: ConfirmingTimeout).perform_later(self)
  end

  def confirm!
    return false unless confirming?
    user = mechanic.user
    user.balance += price
    user.save
    update_attribute(:state, Order.states[:finished])
  end

  def title
    "#{mechanic.user.nickname} #{skill.name}"
  end

  def user_nickname
    user.nickname
  end
end
