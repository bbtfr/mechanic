module MobileVerificationCode
  extend ActiveSupport::Concern

  included do
    include Authlogic::ActsAsAuthentic::VerificationCode

    acts_as_authentic do |config|
      config.login_field = :mobile
    end

    validates_format_of :mobile, with: /\d{11}/
    validates_uniqueness_of :mobile
    validate :send_verification_code, if: :verification_code_changed?

    def reset_verification_code
      self.verification_code = "%06d" % SecureRandom.random_number(1000000)
    end
  end

  def send_verification_code
    return unless mobile =~ /\d{11}/
    result = SMSMailer.confirmation(self).deliver
    # errors.add :base, result[:error] unless result[:success]
  end

  def confirm!
    update_attribute(:confirmed, true)
  end
end
