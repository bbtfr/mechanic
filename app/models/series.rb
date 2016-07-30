class Series < ApplicationRecord
  belongs_to :brand

  validates_presence_of :name, :brand

end
