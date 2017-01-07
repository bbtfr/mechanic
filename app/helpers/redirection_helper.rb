module RedirectionHelper

  def set_redirect key, url
    session[key] = url
  end

  def set_redirect_original_url key
    set_redirect key, request.original_url
  end

  def set_redirect_referer key
    set_redirect key, request.referer
  end

  def fetch_redirect key
    session[key]
  end

  def clear_redirect key
    session.delete key
  end

  def redirect! key, default_url
    redirect_to clear_redirect(key) || default_url
  end

  def redirect_to_referer! default_url = nil
    redirect_to request.referer || default_url
  end

end
