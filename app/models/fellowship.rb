class Fellowship < ActiveRecord::Base
  belongs_to :mechanic
  belongs_to :user
end
