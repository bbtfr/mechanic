class Mechanic < ActiveRecord::Base
  belongs_to :user

  has_many :orders
  has_and_belongs_to_many :skills

  has_many :fellowships
  has_many :followed_users, through: :fellowships, source: :user

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
    orders.available.count
  end

  def regular_client? user
    user = user.id if user.is_a? User
    orders.where(user_id: user).exists?
  end

  def location_name
    name = ""
    name << province.name if province
    name << " #{city.name}" if city && province.lbs_id != city.lbs_id
    name << " #{district.name}" if district
    name
  end

end
