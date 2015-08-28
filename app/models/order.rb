class Order < ActiveRecord::Base
  belongs_to :skill
  belongs_to :brand
  belongs_to :series

  belongs_to :user
  belongs_to :mechanic
  has_many :bids

  validates_presence_of :skill, :brand, :series, :quoted_price

  as_enum :state, pending: 0, canceled: 1, paid: 2, finished: 3

  after_initialize do
    self.state = :canceled if persisted? && pending? &&
      Time.now - created_at > 3.minutes
  end

end
