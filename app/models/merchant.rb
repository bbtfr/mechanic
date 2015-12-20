class Merchant < ActiveRecord::Base
  include MobileVerificationCode

  attr_accessor :current_password

  as_enum :role, admin: 0, user: 1

  belongs_to :user
  belongs_to :store, foreign_key: :user_id, autosave: true
  accepts_nested_attributes_for :store, update_only: true

  has_many :notes

  validates_presence_of :nickname

  delegate :nickname, :mobile, :address, to: :user, prefix: true

  def inactive!
    update_attribute(:active, false)
  end

  def active!
    update_attribute(:active, true)
  end

end
