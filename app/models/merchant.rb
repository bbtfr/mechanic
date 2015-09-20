class Merchant < ActiveRecord::Base
  include MobileVerificationCode

  attr_accessor :current_password

  belongs_to :user
  belongs_to :store, foreign_key: :user_id, autosave: true
  accepts_nested_attributes_for :store

  validates_presence_of :nickname

end
