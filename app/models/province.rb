class Province < ActiveRecord::Base
  def parent
    self
  end

  def to_scope
    {province_cd: id}
  end
end
