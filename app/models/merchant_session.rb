class MerchantSession < Authlogic::Session::Base
  login_field :mobile

  validate :validate_user_magic_states

  def validate_user_magic_states
    return true if attempted_record.nil?
    user = attempted_record.user
    return true if user.nil?
    [:active, :approved, :confirmed].each do |required_status|
      if user.respond_to?("#{required_status}?") && !user.send("#{required_status}?")
        errors.add(:base, I18n.t("authlogic.error_messages.store_not_#{required_status}", :default => "Your account is not #{required_status}"))
        return false
      end
    end
    true
  end
end
