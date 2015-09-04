class District < ActiveRecord::Base
  belongs_to :city
  alias_attribute :parent, :city
end
