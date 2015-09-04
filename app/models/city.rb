class City < ActiveRecord::Base
  belongs_to :province
  alias_attribute :parent, :province
end
