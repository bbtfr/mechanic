module Weixin
  Config = YAML.load(ERB.new(File.read("#{Rails.root}/config/weixin.yml")).result)[Rails.env]
  Client = WeixinAuthorize::Client.new(Config["app_id"], Config["app_secret"])
  BaseURL = ENV["BASE_URL"] || "http://mechanic.dev.com"

  WxPay.appid = Config["app_id"]
  WxPay.key = Config["pay_key"]
  WxPay.mch_id = Config["mch_id"]

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

    def authorize_url
      Client.authorize_url "#{BaseURL}/session/new"
    end

    def create_menu menu = Menu
      Client.create_menu menu
    end

    def send_order_template_message user, order
      Client.send_template_msg user.weixin_openid,
        OrderTemplate,
        "#{BaseURL}/orders/#{order.id}/bids/new",
        TemplateTopColor,
        {
          "Appointment": format_template_data(I18n.l(order.appointment, format: :long)),
          "OrderType": format_template_data(order.skill.try :name),
          "Brand": format_template_data("#{order.brand.try :name} #{order.series.try :name}"),
          "QuotedPrice": format_template_data(order.quoted_price),
          "Remark": format_template_data("#{order.remark.presence || "无"}\r\n\r\n点击详情去接单！", false)
        }
    end

    def format_template_data value, newline = true
      value = value.to_s
      value << "\r\n" if newline
      { value: value, color: TemplateDataColor }
    end

    def payment user, order, request
      access_token = Rails.cache.fetch(:wechat_pay_access_token, expires_in: 7200.seconds, raw: true) do
        WechatPay::AccessToken.generate[:access_token]
      end

      params = {
        body:             'body',
        traceid:          user.id.to_s,      # Your user id
        out_trade_no:     order.id.to_s,     # Your order id
        total_fee:        order.price.to_s,  # 注意：单位是分，不是元
        notify_url:       'http://your_domain.com/notify',
        spbill_create_ip: request.host_ip
      }

      WechatPay::App.payment(access_token, params)
    end

    def method_missing method, *args
      if Client.respond_to? method
        Client.send method, *args
      else
        super
      end
    end
  end
end
