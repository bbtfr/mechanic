class User < ActiveRecord::Base
  include MobileVerificationCode
  include Followable

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
  has_one :merchant

  has_one :owner_user_group, -> { confirmeds }, class_name: "UserGroup"

  belongs_to :user_group

  validates_presence_of :nickname, :gender, :address, if: :confirmed

  delegate :province_id, :city_id, :district_id, :skill_ids, :description,
    to: :mechanic, allow_nil: true

  def total_cost
    orders.availables.sum(:price) || 0
  end

  def orders_count
    orders.availables.count
  end
end
