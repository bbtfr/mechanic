class Bid < ActiveRecord::Base
  belongs_to :mechanic
  belongs_to :order

  validates_uniqueness_of :mechanic_id, scope: :order_id
end
