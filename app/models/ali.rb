module Ali
  Config = YAML.load(ERB.new(File.read("#{Rails.root}/config/alipay.yml")).result)[Rails.env]
  BaseURL = ENV["BASE_URL"] || "http://qichetang.cn"
  MerchantsURL = ENV["MERCHANTS_URL"] || Rails.env.production? ? "http://es.qichetang.cn" : "http://qichetang.cn/merchants"

  Alipay.pid = Config["pid"]
  Alipay.key = Config["key"]

  class << self

    def payment order
      Alipay::Service.create_direct_pay_by_user_url(
        subject: order.title,
        out_trade_no: order.out_trade_no(true),
        total_fee: order.price,
        return_url: "#{MerchantsURL}/orders/#{order.id}/result",
        notify_url: "#{MerchantsURL}/orders/#{order.id}/notify.alipay"
      )
    end

    def refund order
      Alipay::Service.refund_fastpay_by_platform_pwd_url(
        batch_no: order.out_refund_no,
        data: [{
          reason: '系统退款',
          trade_no: order.trade_no,
          amount: order.price
        }],
        notify_url: "#{MerchantsURL}/orders/#{order.id}/notify.alipay"
      )
    end

  end
end
