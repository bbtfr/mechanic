class User < ActiveRecord::Base
  include MobileVerificationCode

  def update_weixin_openid openid
    return unless openid.present?
    self.update_attribute(:weixin_openid, openid)
  end

  alias_attribute :nickname_for_merchant, :nickname

  as_enum :gender, male: 0, female: 1
  as_enum :role, client: 0, mechanic: 1, merchant: 2

  def is_mechanic
    mechanic?
  end

  def is_mechanic= is_mechanic
    self.role = :mechanic if ["1", 1, true].include? is_mechanic
  end

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  has_many :orders
  has_many :fellowships
  has_many :followed_mechanics, through: :fellowships, source: :mechanic

  has_one :mechanic, autosave: true
  has_one :merchant, autosave: true

  has_one :owner_user_group, -> { confirmeds }, class_name: "UserGroup"

  belongs_to :user_group

  validates_presence_of :nickname, :gender, :address, if: :mobile_confirmed

  delegate :province_id, :city_id, :district_id, :skill_ids, :description,
    to: :mechanic, allow_nil: true

  def total_cost
    orders.available.sum(:price) || 0
  end

  def orders_count
    orders.available.count
  end

  def follow! mechanic
    mechanic = mechanic.id if mechanic.is_a? Mechanic
    Fellowship.where(mechanic_id: mechanic, user: self).first_or_create
  end

  def unfollow! mechanic
    mechanic = mechanic.id if mechanic.is_a? Mechanic
    Fellowship.where(mechanic_id: mechanic, user: self).destroy_all
  end

  def follow? mechanic
    mechanic = mechanic.id if mechanic.is_a? Mechanic
    Fellowship.where(mechanic_id: mechanic, user: self).exists?
  end
end
