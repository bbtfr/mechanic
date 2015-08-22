class Order < ActiveRecord::Base
  belongs_to :skill
  belongs_to :brand
  belongs_to :series

  belongs_to :user
  belongs_to :mechanic
  has_many :bids

  validates_presence_of :skill, :brand, :series, :quoted_price

end
