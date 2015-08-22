BASE_URL = ENV["BASE_URL"] || "http://192.168.31.150:3000"

module Weixin
  Config = YAML.load(ERB.new(File.read("#{Rails.root}/config/weixin.yml")).result)[Rails.env]
  Client = WeixinAuthorize::Client.new(Config["appid"], Config["appsecret"])

  OrderTemplate = "-sUkkh2_UVAsIyNTMjlbijfHV2D66H0MGJ2E-eZ6m48"
  TemplateTopColor = "#FF0000"
  TemplateDataColor = "#173177"

  Menu = {
    button: [{
      type: "view",
      name: "预约技师",
      url: "#{BASE_URL}/orders/new"
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
      url: "#{BASE_URL}/user"
    }]
  }

  class << self

    def authorize_url
      Client.authorize_url "#{BASE_URL}/session/new"
    end

    def create_menu menu = Menu
      Client.create_menu menu
    end

    def send_order_template_message user, order
      Client.send_template_msg user.weixin_openid,
        OrderTemplate,
        "#{BASE_URL}/orders/#{order.id}/bids/new",
        TemplateTopColor,
        {
          "Appointment": format_template_data(I18n.l(order.appointment, format: :long)),
          "OrderType": format_template_data(order.skill.name),
          "Brand": format_template_data("#{order.brand.name} #{order.series.name}"),
          "QuotedPrice": format_template_data(order.quoted_price),
          "Remark": format_template_data("#{order.remark.presence || "无"}\r\n\r\n点击详情去接单！", false)
        }
    end

    def format_template_data value, newline = true
      value = value.to_s
      value << "\r\n" if newline
      { value: value, color: TemplateDataColor }
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
