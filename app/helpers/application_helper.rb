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

  def icon_stars stars, total, icon_filled, icon_empty, delimiter = " "
    text = []
    stars.times do
      text << "<span class=\"#{icon_filled}\"></span>"
    end
    (total - stars).times do
      text << "<span class=\"#{icon_empty}\"></span>"
    end
    text.join(delimiter).html_safe
  end

  def ratchet_icon_stars stars, total = 5
    icon_stars stars, total, "icon icon-star-filled", "icon icon-star"
  end

  def bootstrap_icon_stars stars, total = 5
    icon_stars stars, total, "glyphicon glyphicon-star", "glyphicon glyphicon-star-empty"
  end

  def bootstrap_icon_stars_field stars, total = 5
    text = icon_stars stars.to_i, total, "glyphicon glyphicon-star", "glyphicon glyphicon-star-empty", ""
    text << " #{stars}"
    text
  end

  IndexFor.format :bootstrap_icon_stars do |stars|
    bootstrap_icon_stars_field stars
  end
end
