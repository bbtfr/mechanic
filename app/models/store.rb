class Store < ApplicationRecord
  include Followable
  include Balancable
  attr_accessor :recharge_amount

  def settings
    FallbackScopedSettings.for_things self
  end

  self.table_name = "users"

  as_enum :role, client: 0, mechanic: 1, merchant: 2
  after_initialize do
    self.role = :merchant
  end

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100#" },
    url: "/system/users/:attachment/:id_partition/:style/:filename"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  has_many :fellowships, foreign_key: :user_id
  has_many :followed_mechanics, through: :fellowships, source: :mechanic
  has_many :merchants, foreign_key: :user_id
  has_one :merchant, -> { order(id: :asc) }, foreign_key: :user_id
  has_many :orders, foreign_key: :user_id

  has_many :notes

  scope :confirmeds, -> { where(confirmed: true) }
  scope :unconfirmeds, -> { where(confirmed: false) }

  default_scope -> { where(role_cd: User.roles[:merchant]) }

  validates_presence_of :nickname, :qq

  def host?
    host
  end

  def confirm!
    update_attribute(:confirmed, true)
  end

  def inactive!
    update_attribute(:active, false)
  end

  def active!
    update_attribute(:active, true)
  end

  def total_cost
    orders.availables.sum(:quoted_price) + orders.availables.sum(:markup_price) || 0
  end

  def available_orders_count
    orders.availables.count
  end

end
