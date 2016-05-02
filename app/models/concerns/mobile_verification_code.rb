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

    attr_accessor :verification_code_sent

    def reset_verification_code
      self.verification_code = "%06d" % SecureRandom.random_number(1000000)
    end
  end

  def send_verification_code
<<<<<<< 0fd53286797b3a196d329ac6290dd3d2f944907b
    return unless mobile =~ /^\d{11}$/
=======
    return unless mobile =~ /\A\d{11}\z/
>>>>>>> fix mobile regex
    return if @skip_send_verification_code
    result = SMSMailer.confirmation(self).deliver
    if result[:success]
      self.verification_code_sent = true
    else
      errors.add :base, result[:error]
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
