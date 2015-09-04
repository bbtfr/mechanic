class Province < ActiveRecord::Base
  def parent
    self
  end
end
