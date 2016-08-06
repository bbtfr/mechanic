class Administrator < ApplicationRecord
  include MobileVerificationCode

  attr_accessor :current_password

  as_enum :role, admin: 0, operator: 1

  validates_presence_of :nickname

  def inactive!
    update_attribute(:active, false)
  end

  def active!
    update_attribute(:active, true)
  end

end
