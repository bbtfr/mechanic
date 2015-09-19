class MerchantSession < Authlogic::Session::Base
  login_field :mobile

end
