module ApplicationHelper
  def goback_link title = "返回"
    link_to title, request.referer, class: "btn btn-block btn-negative"
  end

  def tel_link_to mobile
    link_to mobile.to_s, "tel:#{mobile}"
  end
end
