class Order < ActiveRecord::Base
  PendingTimeout = 5.minutes
  PayingTimeout = 5.minutes

  attr_accessor :adcode

  belongs_to :skill
  belongs_to :brand
  belongs_to :series

  belongs_to :user
  belongs_to :mechanic
  belongs_to :bid
  has_many :bids

  as_enum :state, pending: 0, canceled: 1, paid: 2, working: 3, finished: 4

  validates_presence_of :skill, :brand, :series, :quoted_price

  after_initialize do
    if persisted? && pending?
      if (!mechanic_id && Time.now - created_at > PendingTimeout) ||
        (mechanic_id && Time.now - updated_at > PayingTimeout)
          update_attribute(:state_cd, Order.states[:canceled])
      end
    end
  end

  def mechanic_nickname
    mechanic && mechanic.user_nickname
  end

  after_create do
    UpdateOrderStateJob.set(wait: PendingTimeout).perform_later(self)
  end

  def pick bid
    return false if canceled?
    UpdateOrderStateJob.set(wait: PayingTimeout).perform_later(self)
    self.bid_id = bid.id
    self.mechanic_id = bid.mechanic_id
    self.price = quoted_price + bid.markup_price
    save
  end

  def title
    "#{mechanic.user.nickname} #{skill.name}"
  end
end
