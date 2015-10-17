class City < ActiveRecord::Base
  belongs_to :province
  alias_attribute :parent, :province

  def to_scope
    {city_cd: id}
  end
end
