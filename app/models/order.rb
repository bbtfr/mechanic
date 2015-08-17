class Order < ActiveRecord::Base
  belongs_to :order_type
  belongs_to :brand
  belongs_to :series

  belongs_to :mechanic

end
