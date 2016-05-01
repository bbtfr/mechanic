module Hidable
  extend ActiveSupport::Concern

  included do
    scope :hidden, -> { where(hidden: true) }
    scope :shown, -> { where.not(hidden: true) }
  end

  def hide!
    update_attribute(:hidden, true)
  end

  def unhide!
    update_attribute(:hidden, false)
  end

  def hidden?
    hidden
  end
end
