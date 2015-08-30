class UserGroup < ActiveRecord::Base
  validates_presence_of :nickname
end
