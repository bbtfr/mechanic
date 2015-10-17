module ApplicationHelper
  def goback_link title = "返回"
    link_to title, request.referer, class: "btn btn-block btn-negative"
  end

  def tel_link_to mobile
    link_to mobile.to_s, "tel:#{mobile}"
  end

  def types_option_pairs klass, group_by
    klass.all.group_by(&group_by).map do |key, value|
      values = value.map do |obj|
        [obj.name, obj.id]
      end
      [key, values]
    end.to_h
  end
end
