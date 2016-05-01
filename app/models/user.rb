class User < ActiveRecord::Base
  include MobileVerificationCode
  include Followable
  include Hidable

  def update_weixin_openid openid
    return unless openid.present?
    self.update_attribute(:weixin_openid, openid)
  end

  alias_attribute :nickname_for_merchant, :nickname

  as_enum :gender, male: 0, female: 1
  as_enum :role, client: 0, mechanic: 1, merchant: 2

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  has_many :orders
  has_many :withdrawals

  has_many :fellowships
  has_many :followed_mechanics, through: :fellowships, source: :mechanic

  has_one :mechanic, autosave: true
  accepts_nested_attributes_for :mechanic, update_only: true

  def mechanic_attributes= attributes
    client! && return if ["0", 0, false].include? attributes["_create"]
    mechanic! if ["1", 1, true].include? attributes["_create"]
    super
  end

  has_one :merchant

  has_one :owner_user_group, -> { confirmeds }, class_name: "UserGroup"

  belongs_to :user_group

  scope :confirmeds, -> { where(confirmed: true) }
  scope :unconfirmeds, -> { where(confirmed: false) }

  scope :location_scope, -> (location) { joins(:mechanic).where(mechanics: location.to_scope) }
  scope :skill_scope, -> (skill) { joins(:mechanic).
    joins(%{INNER JOIN "mechanics_skills" ON "mechanics"."id" = "mechanics_skills"."mechanic_id"}).
    where(%{"mechanics_skills"."skill_id" = ?}, Mechanic.skills.value(skill))
  }

  validates_presence_of :nickname, :gender, :address, if: :confirmed

  def increase_balance! amount, reason = "", source = nil
    Metric.audit self, source, :balance, reason: reason, amount: amount
    increment!(:balance, amount)
  end

  def increase_total_cost! amount
    increment!(:total_cost, amount)
  end

  def raw_available_orders_count
    orders.availables.count || 0
  end
end
