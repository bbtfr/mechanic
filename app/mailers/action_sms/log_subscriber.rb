module ActionSMS
  class LogSubscriber < ActiveSupport::LogSubscriber
    def deliver(event)
      return unless logger.info?
      recipients = Array(event.payload[:to]).join(', ')
      info("\nSent SMS to #{recipients} (#{event.duration.round(1)}ms)")
      debug(event.payload[:sms])
    end

    def logger
      ActionSMS::Base.logger
    end
  end
end

ActionSMS::LogSubscriber.attach_to :action_sms
