class User < ActiveRecord::Base
  include Authlogic::ActsAsAuthentic::VerificationCode

  acts_as_authentic do |config|
    config.login_field = :mobile
  end

  def reset_verification_code
    self.verification_code = "%06d" % SecureRandom.random_number(1000000)
  end

  validates_presence_of :mobile
  validates_presence_of :nickname, :gender, :address, if: :mobile_confirmed
  validates_uniqueness_of :mobile

  as_enum :gender, male: 0, female: 1

  has_many :orders
  has_one :user_group

end
