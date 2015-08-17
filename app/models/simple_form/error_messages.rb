module SimpleForm
  class ErrorMessages
    delegate :object, :object_name, :template, to: :@builder

    def initialize(builder, options)
      @builder = builder
      @message = options.delete(:message)
      @options = options
    end

    def render
      if has_errors?
        template.content_tag(error_messages_tag, html_options) do
          messages = template.content_tag(error_messages_list_tag) do
            object.errors.full_messages.map do |message|
              template.content_tag(error_messages_item_tag) do
                message
              end
            end.join.html_safe
          end
          error_notification + messages
        end
      end
    end

    protected

    def errors
      object.errors
    end

    def has_errors?
      object && object.respond_to?(:errors) && errors.present?
    end

    def error_notification
      (@message || translate_error_notification).html_safe
    end

    def error_messages_tag
      SimpleForm.error_notification_tag
    end

    def error_messages_list_tag
      SimpleForm.error_messages_list_tag
    end

    def error_messages_item_tag
      SimpleForm.error_messages_item_tag
    end

    def html_options
      @options[:class] = "#{SimpleForm.error_notification_class} #{@options[:class]}".strip
      @options
    end

    def translate_error_notification
      lookups = []
      lookups << :"#{object_name}"
      lookups << :default_message
      lookups << "Please review the problems below:"
      I18n.t(lookups.shift, scope: :"simple_form.error_notification", default: lookups)
    end
  end
end

module SimpleForm

  mattr_accessor :error_messages_list_tag
  @@error_messages_list_tag = :ul

  mattr_accessor :error_messages_item_tag
  @@error_messages_item_tag = :li

  class FormBuilder
    def error_messages(options = {})
      SimpleForm::ErrorMessages.new(self, options).render
    end
  end
end

