# encoding: utf-8
# Use this hook to configure WeixinRailsMiddleware bahaviors.
WeixinRailsMiddleware.configure do |config|
  Config = YAML.load(ERB.new(File.read("#{Rails.root}/config/weixin.yml")).result)[Rails.env]

  ## NOTE:
  ## If you config all them, it will use `weixin_token_string` default

  ## Config public_account_class if you SAVE public_account into database ##
  # Th first configure is fit for your weixin public_account is saved in database.
  # +public_account_class+ The class name that to save your public_account
  # config.public_account_class = "PublicAccount"

  ## Here configure is for you DON'T WANT TO SAVE your public account into database ##
  # Or the other configure is fit for only one weixin public_account
  # If you config `weixin_token_string`, so it will directly use it
  config.weixin_token_string = Config["middleware_token"]
  # using to weixin server url to validate the token can be trusted.
  config.weixin_secret_string = Config["middleware_secret"]
  # 加密配置，如果需要加密，配置以下参数
  # config.encoding_aes_key = 'dd837765fede73273b1e4cb3f846469abd3e08d6fed'
  config.app_id = Config["app_id"]

  ## You can custom your adapter to validate your weixin account ##
  # Wiki https://github.com/lanrion/weixin_rails_middleware/wiki/Custom-Adapter
  # config.custom_adapter = "MyCustomAdapter"

end
