class UserGroup < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :nickname

  scope :confirmeds, proc { where(confirmed: true) }
  scope :unconfirmeds, proc { where.not(confirmed: true) }

  def confirm!
    update_attribute(:confirmed, true)
  end

end
