module ApplicationHelper
  def form_field form, field, key, *options
    content_tag :div, class: "field" do
      form.label(key) + form.send(field, key, *options)
    end
  end

  def errors_alert errors
    return if errors.empty?
    content_tag :ul, class: "alert alert-danger" do
      errors.full_messages.map do |msg|
        content_tag :li, msg
      end.join.html_safe
    end
  end

  def flash_alert flash
    flash.each do |level, msg|
      content_tag :div, class: "alert alert-#{level}" do
        msg
      end
    end
  end
end
