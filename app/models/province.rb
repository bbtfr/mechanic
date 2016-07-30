class Province < ApplicationRecord
  has_many :cities

  def parent
    self
  end

  def to_scope
    { province_cd: id }
  end
end
