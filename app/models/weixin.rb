module Weixin
  Config = YAML.load(ERB.new(File.read("#{Rails.root}/config/weixin.yml")).result)[Rails.env]
  BaseURL = ENV["BASE_URL"] || "http://mechanic.dev.com"

  WxPay.appid = Config["app_id"]
  WxPay.key = Config["pay_key"]
  WxPay.mch_id = Config["mch_id"].to_s

  Client = WeixinAuthorize::Client.new(Config["app_id"], Config["app_secret"])

  OrderTemplate = Config["order_template_id"]
  TemplateTopColor = "#FF0000"
  TemplateDataColor = "#173177"

  Menu = {
    button: [{
      type: "view",
      name: "预约技师",
      url: "#{BaseURL}/orders/new"
    }, {
      name: "服务",
      sub_button: [
      {
        type: "view",
        name: "店家教程",
        url: "http://www.baidu.com/"
      },
      {
        type: "view",
        name: "技师教程",
        url: "http://www.baidu.com/"
      },
      {
        type: "view",
        name: "售后电话",
        url: "http://www.baidu.com/"
      }]
    }, {
      type: "view",
      name: "我的",
      url: "#{BaseURL}/user"
    }]
  }

  class << self

    def authorize_url redirect = "#{BaseURL}/session/new"
      weixin_authorize_client_send :authorize_url, redirect
    end

    def create_menu menu = Menu
      weixin_authorize_client_send :create_menu, menu
    end

    def send_order_template_message user, order
      weixin_authorize_client_send :send_template_msg,
        user.weixin_openid,
        OrderTemplate,
        "#{BaseURL}/orders/#{order.id}/bids/new",
        TemplateTopColor,
        {
          first: format_template_data("#{order.user.nickname} 刚刚发布了新订单"),
          keyword1: format_template_data(I18n.l(order.appointment, format: :long)),
          keyword2: format_template_data(order.skill.try :name),
          keyword3: format_template_data("#{order.brand.try :name} #{order.series.try :name}"),
          keyword4: format_template_data("#{order.quoted_price} 元"),
          keyword5: format_template_data(order.remark.presence || "无"),
          remark: format_template_data("\r\n点击详情去接单！")
        }
    end

    def weixin_authorize_client_send method, *args
      Rails.logger.info "  Requested WeixinAuthorize API #{method} with params #{args.join(", ")}"
      response = Client.send method, *args
      raise response.en_msg if response.is_a?(WeixinAuthorize::ResultHandler) && response.code != 0
      response
    rescue Exception => e
      Rails.logger.error "  Error occurred when requesting WeixinAuthorize API: #{e.message}"
      raise
    end

    def method_missing method, *args
      if Client.respond_to? method
        weixin_authorize_client_send method, *args
      else
        super
      end
    end

    def format_template_data value
      value = value.to_s
      { value: value, color: TemplateDataColor }
    end

    def payment user, order, remote_ip
      params = {
        body: order.title,
        out_trade_no: "order#{order.id}created_at#{order.created_at.to_i}",
        total_fee: 1,
        spbill_create_ip: remote_ip,
        notify_url: "#{BaseURL}/orders/#{order.id}/notify",
        trade_type: "JSAPI", # could be "JSAPI", "NATIVE" or "APP",
        openid: user.weixin_openid # required when trade_type is `JSAPI`
      }

      Rails.logger.info("  Requested WxPay API invoke_unifiedorder with params #{params}")
      response = WxPay::Service.invoke_unifiedorder params
      Rails.logger.info("  Result: #{response}")

      return false unless response.success?

      params = {
        appId: Config["app_id"],
        timeStamp: Time.now.to_i.to_s,
        nonceStr: SecureRandom.hex,
        package: "prepay_id=#{response["prepay_id"]}",
        signType: "MD5"
      }
      pay_sign = WxPay::Sign.generate(params)

      Rails.logger.info("  Requested WxPay API generate with params #{params}")
      params.merge!(paySign: pay_sign)
      Rails.logger.info("  Result: #{params}")

      params
    rescue Exception => e
      Rails.logger.error("  Error occurred when requesting WxPay API: #{e.message}")
    end

    def audit_subscribe_event keyword, weixin_openid
      if keyword =~ /(\w+)(\d+)/
        type, id = $1.to_sym, $2.to_i
        Rails.logger.info "  Audit: #{type}, #{weixin_openid}, #{id} "
        WeixinAuthorize.weixin_redis.hset type, weixin_openid, id
      end
    end

    def callback_signup_event user, weixin_openid
      group_id = WeixinAuthorize.weixin_redis.hget "qrscene_user_groups", weixin_openid
      return unless group_id
      WeixinAuthorize.weixin_redis.hdel "qrscene_user_groups", weixin_openid
      Rails.logger.info "  Audit: qrscene_user_groups, #{weixin_openid}, #{group_id} "
      user.update_attribute(:user_group_id, group_id)
    end

  end
end
