module MobileVerificationCode
  extend ActiveSupport::Concern

  included do
    include Authlogic::ActsAsAuthentic::VerificationCode

    acts_as_authentic do |config|
      config.login_field = :mobile
    end

    validates_format_of :mobile, with: /\A\d{11}\z/
    validates_uniqueness_of :mobile
    validate :send_verification_code, if: :verification_code_changed?

    before_validation :ensure_mobile_format
    def ensure_mobile_format
      self.mobile.strip! if mobile
    end

    attr_accessor :verification_code_sent

    def reset_verification_code
      self.verification_code = "%06d" % SecureRandom.random_number(1000000)
    end
  end

  def send_verification_code
    return unless mobile =~ /\A\d{11}\z/
    return if @skip_send_verification_code
    result = SMS.send_confirmation_message(self)
    if result["result"] == "0"
      self.verification_code_sent = true
    else
      errors.add :base, SMS::ERROR_MESSAGE_MAPPING[result["result"]]
    end
  end

  def skip_send_verification_code
    @skip_send_verification_code = true
    self.confirmed = true
  end

  def confirm!
    update_attribute(:confirmed, true)
  end
end
