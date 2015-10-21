class Mechanic < ActiveRecord::Base
  belongs_to :user

  has_many :orders

  has_many :fellowships
  has_many :followed_users, through: :fellowships, source: :user

  as_enum :province, Province, persistence: true
  as_enum :city, City, persistence: true
  as_enum :district, District, persistence: true
  as_enum :skills, Skill, persistence: true, accessor: :join_table

  delegate :nickname, :mobile, :address, :weixin_openid, to: :user, prefix: true

  attr_accessor :_check, :_create

  before_create do |record|
    Rails.logger.info "Mechanic#before_create #{record.inspect}"
  end

  before_update do |record|
    Rails.logger.info "Mechanic#before_update #{record.inspect}"
  end

  before_destroy do |record|
    Rails.logger.info "Mechanic#before_destroy #{record.inspect}"
  end

  def professionality_average
    (orders.average(:professionality) || 4).round(2)
  end

  def timeliness_average
    (orders.average(:timeliness) || 4).round(2)
  end

  def total_income
    ((orders.settleds.sum(:price) || 0) * (100 - Setting.commission_percent.to_f) / 100).round(2)
  end

  def orders_count
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
