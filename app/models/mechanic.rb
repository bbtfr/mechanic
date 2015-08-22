class Mechanic < ActiveRecord::Base
  has_and_belongs_to_many :skills
  belongs_to :province
  belongs_to :city
  belongs_to :district

end
