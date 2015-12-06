class Metric < ActiveRecord::Base
  belongs_to :user
  belongs_to :source, polymorphic: true

  serialize :data, Hash

  def self.audit user, source, method, data
    create(user: user, source: source, method: method, data: data)
  end

end
