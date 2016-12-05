module SMS
  Config = YAML.load(ERB.new(File.read("#{Rails.root}/config/sms.yml")).result)[Rails.env]
  Endpoint = "https://yun.tim.qq.com/v3/tlssmssvr/sendsms"

  SDK_APP_ID = Config["sdk_app_id"]
  APP_KEY = Config["app_key"]
  TEMPLATES = Config["templates"]

  class << self

    def send_confirmation_message user
      send_request user.mobile, "confirmation", [user.verification_code]
    end

    def send_refund_order_message order, mechanic
      send_request mechanic.user_mobile, "mechanic_refund_order", [
        [order.contact_nickname, order.contact_mobile].compact.join(" "),
        order.address,
        order.skill,
        order.brand,
        order.series
      ]
    end

    def send_pay_order_message order
      mechanic = order.mechanic

      send_request mechanic.user_mobile, "mechanic_pay_order", [
        order.user_nickname,
        [order.contact_nickname, order.contact_mobile].compact.join(" "),
        order.address,
        I18n.l(order.appointment, format: :long),
        order.skill,
        order.brand,
        order.series,
        order.mechanic_income,
        order.offline? && "【线下交易】",
        order.remark.presence || "无",
      ]

      return unless order.contact_mobile
      common_params = [
        order.contact_nickname || @order.user_nickname,
        order.skill,
        mechanic.user_nickname,
        mechanic.user_mobile,
        mechanic.user_address,
        mechanic.professionality_average,
        mechanic.timeliness_average
      ]

      if order.mobile?
        template = "contact_pay_mobile_order"
        params = common_params
      else
        template = "contact_pay_merchant_order"
        params = [
          "【#{order.store_nickname}】",
          *common_params,
          order.store_hotline
        ]
      end

      send_request order.contact_mobile, template, params
    end

    def send_request phone, template, params
      endpoint = "#{Endpoint}?sdkappid=#{SDK_APP_ID}&random=#{"%04d" % rand(10000)}"
      payload = {
        tel: {
          nationcode: "86",
          phone: phone
        },
        type: "0",
        tpl_id: TEMPLATES[template],
        params: params.map(&:to_s),
        sig: Digest::MD5.hexdigest("#{APP_KEY}#{phone}")
      }.to_json

      Rails.logger.info "  Requested QCloud SMS API #{endpoint} with payload #{payload}"
      response = RestClient.post endpoint, payload
      response = JSON.parse response.body
      raise response["errmsg"] if response["result"] != "0"
      response
    rescue Exception => e
      Rails.logger.error "  Error occurred when requesting QCloud SMS API: #{e.message}"
      response || { "errmsg" => "短信发送失败" }
    end
  end

  ERROR_MESSAGE_MAPPING = {
    "1001" => "AppKey错误",
    "1002" => "短信/语音内容中含有脏字",
    "1003" => "未填AppKey",
    "1004" => "REST API请求参数有误",
    "1006" => "没有权限",
    "1007" => "其他错误",
    "1008" => "下发短信超时",
    "1009" => "用户IP不在白名单中",
    "1011" => "REST API命令字错误",
    "1012" => "短信内容格式错误",
    "1013" => "下发短信频率限制",
    "1014" => "模版未审批",
    "1015" => "黑名单手机",
    "1016" => "错误的手机号格式",
    "1017" => "短信内容过长",
    "1018" => "语音验证码格式错误",
    "1019" => "SDKAppId不存在"
  }
end
