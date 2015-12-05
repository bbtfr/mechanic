class Mechanic < ActiveRecord::Base
  belongs_to :user

  has_many :orders

  has_many :fellowships
  has_many :followed_users, through: :fellowships, source: :user

  has_one :user_group, through: :user

  as_enum :province, Province, persistence: true
  as_enum :city, City, persistence: true
  as_enum :district, District, persistence: true
  as_enum :skills, Skill, persistence: true, accessor: :join_table

  delegate :nickname, :mobile, :address, :weixin_openid, to: :user, prefix: true

  attr_accessor :_check, :_create

  def increase_total_income! amount
    increment!(:total_income, amount)
  end

  def raw_professionality_average
    (orders.average(:professionality) || 4).round(2)
  end

  def raw_timeliness_average
    (orders.average(:timeliness) || 4).round(2)
  end

  def raw_available_orders_count
    orders.availables.count
  end

  def regular_client? user
    user = user.id if user.is_a? User
    orders.where(user_id: user).exists?
  end

  def location_name
    name = []
    name << province if province
    name << city if city && province != city
    name << district if district
    name.join(" ")
  end

end
