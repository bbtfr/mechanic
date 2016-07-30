class City < ApplicationRecord
  belongs_to :province
  alias_attribute :parent, :province
  has_many :districts

  def to_scope
    { city_cd: id }
  end
end
