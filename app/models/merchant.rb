class Merchant < ApplicationRecord
  include MobileVerificationCode

  attr_accessor :current_password

  as_enum :role, admin: 0, dispatcher: 1

  has_many :orders

  belongs_to :user
  belongs_to :store, foreign_key: :user_id, autosave: true
  accepts_nested_attributes_for :store, update_only: true

  validates_presence_of :nickname

  # cache_column :store, :nickname
  # cache_column :store, :mobile
  # cache_column :store, :address
  delegate :nickname, :mobile, :address, to: :store, prefix: true, allow_nil: true

  def inactive!
    update_attribute(:active, false)
  end

  def active!
    update_attribute(:active, true)
  end

end
