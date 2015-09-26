module Followable
  def follow! mechanic
    mechanic = mechanic.id if mechanic.is_a? Mechanic
    Fellowship.where(mechanic_id: mechanic, user: self).first_or_create
  end

  def unfollow! mechanic
    mechanic = mechanic.id if mechanic.is_a? Mechanic
    Fellowship.where(mechanic_id: mechanic, user: self).destroy_all
  end

  def follow? mechanic
    mechanic = mechanic.id if mechanic.is_a? Mechanic
    Fellowship.where(mechanic_id: mechanic, user: self).exists?
  end
end
