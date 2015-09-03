module WxPay
  class << self
    attr_accessor :client_cert, :client_key
  end

  module Service
    INVOKE_TRANSFER_REQUIRED_FIELDS = %i(partner_trade_no openid check_name amount desc spbill_create_ip)
    def self.invoke_transfer params
      params = {
        mch_appid: WxPay.appid,
        mchid: WxPay.mch_id,
        nonce_str: SecureRandom.uuid.tr('-', '')
      }.merge(params)

      check_required_options(params, INVOKE_TRANSFER_REQUIRED_FIELDS)

      r = invoke_remote_with_cert("#{GATEWAY_URL}/mmpaymkttransfers/promotion/transfers", make_payload(params))

      yield r if block_given?

      r
    end

    def self.invoke_remote_with_cert url, payload
      r = RestClient::Request.execute({
        method: :post,
        url: url,
        payload: payload,
        headers: { content_type: 'application/xml' },
        ssl_client_cert: WxPay.client_cert,
        ssl_client_key: WxPay.client_key
      }.merge(WxPay.extra_rest_client_options))

      if r
        WxPay::Result.new Hash.from_xml(r)
      else
        nil
      end
    end
  end

  module Sign
    def self.generate(params)
      query = params.sort.map do |key, value|
        "#{key}=#{value}" if value != "" && !value.nil?
      end.compact.join('&')

      Digest::MD5.hexdigest("#{query}&key=#{WxPay.key}").upcase
    end
  end
end
