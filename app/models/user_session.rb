class UserSession < Authlogic::Session::Base
  include Authlogic::Session::VerificationCode
  include Authlogic::Session::RWField

  login_field :mobile
  rw_field :is_mechanic

end
