class User < ActiveRecord::Base
  include Authlogic::ActsAsAuthentic::VerificationCode

  acts_as_authentic do |config|
    config.login_field = :mobile
  end

  def reset_verification_code
    self.verification_code = "%06d" % SecureRandom.random_number(1000000)
  end

  def update_weixin_openid openid
    return unless openid.present?
    self.update_attribute(:weixin_openid, openid)
  end

  as_enum :gender, male: 0, female: 1

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100#" }
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  has_many :orders
  has_many :fellowships
  has_many :mechanics, through: :fellowships
  has_one :owner_user_group, -> { confirmeds }, class_name: "UserGroup"

  belongs_to :user_group
  belongs_to :mechanic, autosave: true

  validates_format_of :mobile, with: /\d{11}/
  validates_presence_of :mobile
  validates_presence_of :nickname, :gender, :address, if: :mobile_confirmed
  validates_uniqueness_of :mobile
  validate :send_verification_code, if: :verification_code_changed?

  def send_verification_code
    return unless mobile =~ /\d{11}/
    result = SMSMailer.confirmation(self).deliver
    errors.add :base, result[:error] unless result[:success]
  end

  delegate :province_id, :city_id, :district_id, :skill_ids, :description,
    to: :mechanic, allow_nil: true

  def confirm_mobile!
    update_attribute(:mobile_confirmed, true)
  end

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
