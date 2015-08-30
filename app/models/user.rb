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

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  has_many :orders
  belongs_to :user_group
  belongs_to :mechanic, autosave: true

  validates_format_of :mobile, :with => /\d{11}/
  validates_presence_of :mobile
  validates_presence_of :nickname, :gender, :address, if: :mobile_confirmed
  validates_uniqueness_of :mobile

  delegate :province_id, :city_id, :district_id, :skill_ids, :description,
    to: :mechanic, allow_nil: true

  def confirm_mobile!
    update_attribute(:mobile_confirmed, true)
  end

  def total_cost
    0
  end

  def orders_count
    0
  end
end
