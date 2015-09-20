class Store < ActiveRecord::Base
  self.table_name = "users"

  as_enum :role, client: 0, mechanic: 1, merchant: 2
  after_initialize do
    self.role = :merchant
  end

  validates_presence_of :nickname

end
