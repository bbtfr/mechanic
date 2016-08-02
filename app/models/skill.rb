class Skill < ApplicationRecord
  has_and_belongs_to_many :mechanics

  validates_presence_of :name

end
