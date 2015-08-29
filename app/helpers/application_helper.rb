module ApplicationHelper
  def goback_link title = "返回"
    link_to title, request.referer, class: "btn btn-block btn-negative"
  end
end
