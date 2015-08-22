module LBS
  Config = YAML.load(ERB.new(File.read("#{Rails.root}/config/lbs.yml")).result)[Rails.env]
  Key = Config["key"]

  class << self
    def district_list
      JSON.parse RestClient.get("http://apis.map.qq.com/ws/district/v1/list", params: { key: Key })
    end
  end
end
