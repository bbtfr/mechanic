WeixinAuthorize.configure do |config|
  config.redis = Redis.new

  if Rails.env.development?
    config.rest_client_options = {
      timeout: 5,
      open_timeout: 5,
      verify_ssl: false
    }
  end
end
