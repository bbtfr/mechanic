class Store < ActiveRecord::Base
  include Followable

  self.table_name = "users"

  as_enum :role, client: 0, mechanic: 1, merchant: 2
  after_initialize do
    self.role = :merchant
  end

  has_many :fellowships, foreign_key: :user_id
  has_many :followed_mechanics, through: :fellowships, source: :mechanic

  validates_presence_of :nickname

end
