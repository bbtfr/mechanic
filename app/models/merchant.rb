class Merchant < ActiveRecord::Base
  include MobileVerificationCode

  attr_accessor :current_password

  as_enum :role, admin: 0, user: 1

  has_many :orders

  belongs_to :user
  belongs_to :store, foreign_key: :user_id, autosave: true
  accepts_nested_attributes_for :store, update_only: true

  validates_presence_of :nickname

  cache_column :user, :nickname
  cache_column :user, :mobile
  cache_column :user, :address

  def inactive!
    update_attribute(:active, false)
  end

  def active!
    update_attribute(:active, true)
  end

end
