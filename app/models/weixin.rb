module Weixin
  Config = YAML.load(ERB.new(File.read("#{Rails.root}/config/weixin.yml")).result)[Rails.env]
  BaseURL = ENV["BASE_URL"] || "http://qichetang.cn"
  MerchantsURL = ENV["MERCHANTS_URL"] || Rails.env.production? ? "http://es.qichetang.cn" : "http://qichetang.cn/merchants"
  LocalIP = ENV["LOCAL_IP"] || "127.0.0.1"

  WxPay.appid = Config["app_id"].to_s
  WxPay.mch_id = Config["mch_id"].to_s
  WxPay.key = Config["pay_key"]
  WxPay.apiclient_cert_path = File.read(Config["p12_path"]) if Config["p12_path"]

  Client = WeixinAuthorize::Client.new(Config["app_id"], Config["app_secret"])

  OrderTemplate = Config["templates"]["order"]
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
        name: "批发",
        url: "http://mp.weixin.qq.com/bizmall/mallshelf?id=&t=mall/list&biz=MzA3MjYwNzYxMA==&shelf_id=2&showwxpaytitle=1#wechat_redirect"
      }, {
        type: "view",
        name: "工费结算",
        url: "http://mp.weixin.qq.com/s?__biz=MzA3MjYwNzYxMA==&mid=207851238&idx=1&sn=92226aa626e8e9ab45ff5e6c90e58d23#rd"
      }, {
        type: "view",
        name: "接单教程",
        url: "http://mp.weixin.qq.com/s?__biz=MzA3MjYwNzYxMA==&mid=400001510&idx=1&sn=f52d3e55726d342ed15c56e9b40338f6#rd"
      }, {
        type: "view",
        name: "成为堂主",
        url: "http://mp.weixin.qq.com/s?__biz=MzA3MjYwNzYxMA==&mid=400002374&idx=1&sn=d98a87390f02d9e9bc2ed2fb6fc5d7f2#rd"
      }, {
        type: "view",
        name: "联系客服",
        url: "http://mp.weixin.qq.com/s?__biz=MzA3MjYwNzYxMA==&mid=400002961&idx=1&sn=3dc701c788b2979557378bc6f65938f8#rd"
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

    def send_create_order_message user, order
      weixin_authorize_client_send :send_template_msg,
        user.weixin_openid,
        OrderTemplate,
        "#{BaseURL}/orders/#{order.id}/bids/new",
        TemplateTopColor,
        {
          first: format_template_data("#{order.user.nickname} 刚刚发布了新订单"),
          keyword1: format_template_data(I18n.l(order.appointment, format: :long)),
          keyword2: format_template_data(order.skill),
          keyword3: format_template_data("#{order.brand} #{order.series}"),
          keyword4: format_template_data("#{order.quoted_price} 元"),
          keyword5: format_template_data(order.remark.presence || "无"),
          remark: format_template_data("点击详情去接单！")
        }
    end

    def send_pay_order_message order
      weixin_authorize_client_send :send_template_msg,
        order.mechanic.user_weixin_openid,
        OrderTemplate,
        "#{BaseURL}/orders/#{order.id}",
        TemplateTopColor,
        {
          first: format_template_data("#{order.user.nickname} 刚刚指派了新订单"),
          keyword1: format_template_data(I18n.l(order.appointment, format: :long)),
          keyword2: format_template_data(order.skill),
          keyword3: format_template_data("#{order.brand} #{order.series}"),
          keyword4: format_template_data("#{order.mechanic_income} 元"),
          keyword5: format_template_data(order.remark.presence || "无"),
          remark: format_template_data("\r\n点击查看订单详情！")
        }

      return unless order.user.weixin_openid
      weixin_authorize_client_send :send_template_msg,
        order.user.weixin_openid,
        OrderTemplate,
        "#{BaseURL}/orders/#{order.id}",
        TemplateTopColor,
        {
          first: format_template_data("您成功预约技师 #{order.mechanic.user_nickname} 为您 #{order.skill}"),
          keyword1: format_template_data(I18n.l(order.appointment, format: :long)),
          keyword2: format_template_data(order.skill),
          keyword3: format_template_data("#{order.brand} #{order.series}"),
          keyword4: format_template_data("#{order.price} 元"),
          keyword5: format_template_data(order.remark.presence || "无"),
          remark: format_template_data("\r\n点击查看订单详情！")
        }
    end

    def send_rework_order_message order
      weixin_authorize_client_send :send_template_msg,
        order.mechanic.user_weixin_openid,
        OrderTemplate,
        "#{BaseURL}/orders/#{order.id}",
        TemplateTopColor,
        {
          first: format_template_data("#{order.user.nickname} 刚刚申请返工"),
          keyword1: format_template_data(I18n.l(order.appointment, format: :long)),
          keyword2: format_template_data(order.skill),
          keyword3: format_template_data("#{order.brand} #{order.series}"),
          keyword4: format_template_data("#{order.mechanic_income} 元"),
          keyword5: format_template_data(order.remark.presence || "无"),
          remark: format_template_data("\r\n点击查看订单详情！")
        }
    end

    def send_confirm_order_message order
      return unless order.user.weixin_openid
      weixin_authorize_client_send :send_template_msg,
        order.user.weixin_openid,
        OrderTemplate,
        "#{BaseURL}/orders/#{order.id}",
        TemplateTopColor,
        {
          first: format_template_data("#{order.mechanic.user_nickname} 刚刚完成了施工"),
          keyword1: format_template_data(I18n.l(order.appointment, format: :long)),
          keyword2: format_template_data(order.skill),
          keyword3: format_template_data("#{order.brand} #{order.series}"),
          keyword4: format_template_data("#{order.price} 元"),
          keyword5: format_template_data(order.remark.presence || "无"),
          remark: format_template_data("\r\n点击详情去确认完工！")
        }
    end

    def send_refund_order_message order, mechanic
      weixin_authorize_client_send :send_template_msg,
        mechanic.user_weixin_openid,
        OrderTemplate,
        "#{BaseURL}/orders/#{order.id}",
        TemplateTopColor,
        {
          first: format_template_data("您的订单 #{order.user.nickname} 刚刚被取消"),
          keyword1: format_template_data(I18n.l(order.appointment, format: :long)),
          keyword2: format_template_data(order.skill),
          keyword3: format_template_data("#{order.brand} #{order.series}"),
          keyword4: format_template_data("#{order.mechanic_income} 元"),
          keyword5: format_template_data(order.remark.presence || "无"),
          remark: format_template_data("")
        }
    end

    def weixin_authorize_client_send method, *args
      Rails.logger.info "  Requested WeixinAuthorize API #{method} with params #{args.join(", ")}"
      response = Client.send method, *args
      raise response.en_msg if response.is_a?(WeixinAuthorize::ResultHandler) && response.code != 0
      response
    rescue Exception => e
      Rails.logger.error "  Error occurred when requesting WeixinAuthorize API: #{e.message}"
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
        out_trade_no: order.out_trade_no,
        total_fee: order.price * 100,
        spbill_create_ip: remote_ip,
        notify_url: "#{BaseURL}/orders/#{order.id}/notify",
        trade_type: "JSAPI", # could be "JSAPI", "NATIVE" or "APP",
        openid: user.weixin_openid # required when trade_type is `JSAPI`
      }

      Rails.logger.info("  Requested WxPay API invoke_unifiedorder with params #{params}")
      response = WxPay::Service.invoke_unifiedorder params
      Rails.logger.info("  Result: #{response}")

      return false, response unless response.success?

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

      return params, response
    rescue Exception => e
      Rails.logger.error("  Error occurred when requesting WxPay API: #{e.message}")
    end

    def payment_qrcode order
      params = {
        body: order.title,
        out_trade_no: order.out_trade_no,
        product_id: order.to_global_id.to_s,
        total_fee: order.price * 100,
        spbill_create_ip: LocalIP,
        notify_url: "#{MerchantsURL}/orders/#{order.id}/notify.weixin",
        trade_type: "NATIVE", # could be "JSAPI", "NATIVE" or "APP",
      }

      Rails.logger.info("  Requested WxPay API invoke_unifiedorder with params #{params}")
      response = WxPay::Service.invoke_unifiedorder params
      Rails.logger.info("  Result: #{response}")

      response
    end

    def recharge_qrcode recharge
      params = {
        body: recharge.title,
        out_trade_no: recharge.out_trade_no,
        product_id: recharge.to_global_id.to_s,
        total_fee: recharge.amount * 100,
        spbill_create_ip: LocalIP,
        notify_url: "#{MerchantsURL}/admin/recharges/#{recharge.id}/notify.weixin",
        trade_type: "NATIVE", # could be "JSAPI", "NATIVE" or "APP",
      }

      Rails.logger.info("  Requested WxPay API invoke_unifiedorder with params #{params}")
      response = WxPay::Service.invoke_unifiedorder params
      Rails.logger.info("  Result: #{response}")

      response
    end

    def refund order
      params = {
        out_trade_no: order.out_trade_no,
        out_refund_no: order.out_refund_no,
        total_fee: order.price * 100,
        refund_fee: order.price * 100
      }

      Rails.logger.info("  Requested WxPay API invoke_refund with params #{params}")
      response = WxPay::Service.invoke_refund params
      Rails.logger.info("  Result: #{response}")

      return response
    end

    def withdrawal withdrawal
      params = {
        desc: withdrawal.title,
        partner_trade_no: withdrawal.out_trade_no,
        amount: withdrawal.amount * 100,
        check_name: "NO_CHECK",
        spbill_create_ip: LocalIP,
        openid: withdrawal.user.weixin_openid
      }

      Rails.logger.info("  Requested WxPay API invoke_transfer with params #{params}")
      response = WxPay::Service.invoke_transfer params
      Rails.logger.info("  Result: #{response}")

      return response
    end

    def audit_subscribe_event keyword, weixin_openid
      if keyword =~ /(\w+?)_(\d+)/
        type, id = $1.to_sym, $2.to_i
        Rails.logger.info "  Audit: Scan QRCode #{type}, #{weixin_openid}, #{id}"
        if User.where(weixin_openid: weixin_openid).exists?
          Rails.logger.warn "  Audit: User already exists."
        else
          WeixinAuthorize.weixin_redis.hset type, weixin_openid, id
        end
      end
    end

    def callback_signup_event user, weixin_openid
      group_id = WeixinAuthorize.weixin_redis.hget "user_group", weixin_openid
      return unless group_id
      WeixinAuthorize.weixin_redis.hdel "user_group", weixin_openid
      Rails.logger.info "  Audit: Apply UserGroup #{weixin_openid}, #{group_id}"
      user.safe_change_group(group_id)
    end

  end
end
