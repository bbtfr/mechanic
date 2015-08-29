class Order < ActiveRecord::Base
  PendingTimeout = 30.minutes

  attr_accessor :adcode

  belongs_to :skill
  belongs_to :brand
  belongs_to :series

  belongs_to :user
  belongs_to :mechanic
  has_many :bids

  as_enum :state, pending: 0, canceled: 1, paid: 2, finished: 3

  validates_presence_of :skill, :brand, :series, :quoted_price

  after_initialize do
    self.state = :canceled if persisted? && pending? &&
      Time.now - created_at > PendingTimeout
  end

end
