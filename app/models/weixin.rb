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
          first: format_template_data("新订单"),
          keyword1: format_template_data(order.skill.try :name),
          keyword2: format_template_data("担保交易 #{order.quoted_price} 元"),
          keyword3: format_template_data(I18n.l(order.appointment, format: :long)),
          keyword4: format_template_data(order.address),
          keyword5: format_template_data("#{order.brand.try :name} #{order.series.try :name}"),
          remark: format_template_data("#{order.remark.presence}\r\n点击详情去接单！")
        }
    end

    def weixin_authorize_client_send method, *args
      Rails.logger.info "  Requested WeixinAuthorize API #{method} with params #{args.join(", ")}"
      response = Client.send method, *args
      raise response if response.is_a?(WeixinAuthorize::ResultHandler) && response.code != 0
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
        notify_url: "#{BaseURL}/notify",
        trade_type: "JSAPI", # could be "JSAPI", "NATIVE" or "APP",
        openid: user.weixin_openid # required when trade_type is `JSAPI`
      }

      Rails.logger.info("  Requested WxPay API invoke_unifiedorder with params #{params}")
      response = WxPay::Service.invoke_unifiedorder params
      Rails.logger.info("  Result: #{response}")

      return false unless response.success?

      params = {
        # fetch by call invoke_unifiedorder with `trade_type` is `APP`
        prepayid: response["prepay_id"],
        # must same as given to invoke_unifiedorder
        noncestr: response["nonce_str"]
      }
      Rails.logger.info("  Requested WxPay API generate_app_pay_req with params #{params}")
      order_params = WxPay::Service::generate_app_pay_req params
      Rails.logger.info("  Result: #{order_params}")

      order_params
    rescue Exception => e
      Rails.logger.error("  Error occurred when requesting WxPay API: #{e.message}")
    end
  end
end
