class Mechanic < ActiveRecord::Base
  has_and_belongs_to_many :skills
  belongs_to :province
  belongs_to :city
  belongs_to :district
  has_one :user

  def orders_count
    0
  end

  def professionality_average
    5
  end

  def timeliness_average
    5
  end

  def user_nickname
    user.nickname
  end
end
