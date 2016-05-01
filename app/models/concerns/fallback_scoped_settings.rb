class FallbackScopedSettings

  def initialize settings
    @settings = settings
  end

  def self.for_things *things
    settings = things.map do |thing|
      RailsSettings::ScopedSettings.for_thing thing if thing
    end.compact
    settings.push ::Setting
    self.new settings
  end

  def [] key
    @settings.find do |settings|
      value = settings[key]
      return value if value
    end
    nil
  end

  def method_missing method, *args, &block
    self[method]
  end

end
