# encoding: utf-8
# 1, @weixin_message: 获取微信所有参数.
# 2, @weixin_public_account: 如果配置了public_account_class选项,则会返回当前实例,否则返回nil.
# 3, @keyword: 目前微信只有这三种情况存在关键字: 文本消息, 事件推送, 接收语音识别结果
WeixinRailsMiddleware::WeixinController.class_eval do

  def reply
    message = send("response_#{@weixin_message.MsgType}_message", {})
    if message.kind_of? String
      Rails.logger.info("  Render reply message: #{message}")
      render xml: message
    else
      render nothing: true
    end
  end

  def info message
    Rails.logger.info("  WeixinRailsMiddleware: #{message}")
  end

  private

    def response_text_message(options={})
      # info("Text message: #{@keyword}")
      reply_transfer_customer_service_message
    end

    # <Location_X>23.134521</Location_X>
    # <Location_Y>113.358803</Location_Y>
    # <Scale>20</Scale>
    # <Label><![CDATA[位置信息]]></Label>
    def response_location_message(options={})
      # @lx    = @weixin_message.Location_X
      # @ly    = @weixin_message.Location_Y
      # @scale = @weixin_message.Scale
      # @label = @weixin_message.Label
      # info("Location: #{@lx}, #{@ly}, #{@scale}, #{@label}")
      reply_transfer_customer_service_message
    end

    # <PicUrl><![CDATA[this is a url]]></PicUrl>
    # <MediaId><![CDATA[media_id]]></MediaId>
    def response_image_message(options={})
      # @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
      # @pic_url  = @weixin_message.PicUrl  # 也可以直接通过此链接下载图片, 建议使用carrierwave.
      # info("Image message: #{@keyword}")
      # # reply_image_message(generate_image(@media_id))
      reply_transfer_customer_service_message
    end

    # <Title><![CDATA[公众平台官网链接]]></Title>
    # <Description><![CDATA[公众平台官网链接]]></Description>
    # <Url><![CDATA[url]]></Url>
    def response_link_message(options={})
      # @title = @weixin_message.Title
      # @desc  = @weixin_message.Description
      # @url   = @weixin_message.Url
      # info("Link message")
      reply_transfer_customer_service_message
    end

    # <MediaId><![CDATA[media_id]]></MediaId>
    # <Format><![CDATA[Format]]></Format>
    def response_voice_message(options={})
      # @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
      # @format   = @weixin_message.Format
      # # 如果开启了语音翻译功能，@keyword则为翻译的结果
      # info("Voice message: #{@keyword}")
      # # reply_voice_message(generate_voice(@media_id))
      reply_transfer_customer_service_message
    end

    # <MediaId><![CDATA[media_id]]></MediaId>
    # <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
    def response_video_message(options={})
      # @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
      # # 视频消息缩略图的媒体id，可以调用多媒体文件下载接口拉取数据。
      # @thumb_media_id = @weixin_message.ThumbMediaId
      # info("Video message")
      reply_transfer_customer_service_message
    end

    def response_event_message(options={})
      event_type = @weixin_message.Event
      send("handle_#{event_type.downcase}_event")
    end

    def handle_scan_keyword
      if @keyword.present?
        # # 扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送
        # info("Subscribe event: 1. User unsubscribed, keyword: #{@keyword}")
        Weixin.audit_subscribe_event @keyword, @weixin_message["FromUserName"]
      end
    end

    # 关注公众账号
    def handle_subscribe_event
      handle_scan_keyword
      info("Subscribe")
      reply_text_message <<-EOS
欢迎关注汽车堂助手。我是你贴身的汽车服务小伙伴。致力于提供更专业、更靠谱的服务。

使用向导
【派单方使用教程】<a href="http://mp.weixin.qq.com/s?__biz=MzA3MjYwNzYxMA==&mid=207851238&idx=1&sn=92226aa626e8e9ab45ff5e6c90e58d23#rd">点击查看教程</a>
【接单方使用教程】<a href="http://mp.weixin.qq.com/s?__biz=MzA3MjYwNzYxMA==&mid=400001510&idx=1&sn=f52d3e55726d342ed15c56e9b40338f6#rd">点击查看教程</a>
EOS
    end

    # 取消关注
    def handle_unsubscribe_event
      info("Unsubscribe")
    end

    # 扫描带参数二维码事件: 2. 用户已关注时的事件推送
    def handle_scan_event
      handle_scan_keyword
      info("Scan event: 2. User subscribed, keyword: #{@keyword}")
    end

    def handle_location_event # 上报地理位置事件
      @lat = @weixin_message.Latitude
      @lgt = @weixin_message.Longitude
      @precision = @weixin_message.Precision
      info("Location: #{@lat}, #{@lgt}, #{@precision}")
    end

    # 点击菜单拉取消息时的事件推送
    def handle_click_event
      info("Click event: #{@keyword}")
    end

    # 点击菜单跳转链接时的事件推送
    def handle_view_event
      info("View event: #{@keyword}")
    end

    # 帮助文档: https://github.com/lanrion/weixin_authorize/issues/22

    # 由于群发任务提交后，群发任务可能在一定时间后才完成，因此，群发接口调用时，仅会给出群发任务是否提交成功的提示，若群发任务提交成功，则在群发任务结束时，会向开发者在公众平台填写的开发者URL（callback URL）推送事件。

    # 推送的XML结构如下（发送成功时）：

    # <xml>
    # <ToUserName><![CDATA[gh_3e8adccde292]]></ToUserName>
    # <FromUserName><![CDATA[oR5Gjjl_eiZoUpGozMo7dbBJ362A]]></FromUserName>
    # <CreateTime>1394524295</CreateTime>
    # <MsgType><![CDATA[event]]></MsgType>
    # <Event><![CDATA[MASSSENDJOBFINISH]]></Event>
    # <MsgID>1988</MsgID>
    # <Status><![CDATA[sendsuccess]]></Status>
    # <TotalCount>100</TotalCount>
    # <FilterCount>80</FilterCount>
    # <SentCount>75</SentCount>
    # <ErrorCount>5</ErrorCount>
    # </xml>
    def handle_masssendjobfinish_event
      info("Mass send job finish event")
    end

    def handle_templatesendjobfinish_event
      info("Template send job finish event")
    end

    def handle_kf_create_session_event
      info("KF create session event")
    end

    def handle_kf_close_session_event
      info("KF close session event")
    end
end
