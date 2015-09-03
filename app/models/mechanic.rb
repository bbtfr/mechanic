class Mechanic < ActiveRecord::Base
  has_one :user
  has_many :orders
  has_and_belongs_to_many :skills

  has_many :fellowships
  has_many :users, through: :fellowships

  belongs_to :province
  belongs_to :city
  belongs_to :district

  def professionality_average
    (orders.average(:professionality) || 4).round(2)
  end

  def timeliness_average
    (orders.average(:timeliness) || 4).round(2)
  end

  def user_nickname
    user.nickname
  end

  def total_income
    orders.finisheds.sum(:price) || 0
  end

  def orders_count
    orders.available.count || 0
  end
end
