class Bid < ActiveRecord::Base
  belongs_to :mechanic
  belongs_to :order

  validates_numericality_of :markup_price, greater_than_or_equal_to: 0
  validates_uniqueness_of :mechanic_id, scope: :order_id
end
