class District < ApplicationRecord
  belongs_to :city
  alias_attribute :parent, :city

  def to_scope
    { district_cd: id }
  end
end
