module LocaleHelper
  # Generates a URL for the current page with the specified locale subdomain
  #
  # @example
  #   # If current URL is http://en.example.com/posts
  #   locale_url_for(fr_locale) # => http://fr.example.com/posts
  #   locale_url_for(de_locale) # => http://de.example.com/posts
  def locale_url_for(locale)
    return request.original_url unless locale

    subdomain = locale.subdomains.order(:created_at).first
    return request.original_url unless subdomain

    uri = URI.parse(request.original_url)
    host_parts = uri.host.split(".")

    if request.subdomains.any?
      if locale == default_locale
        host_parts.shift # Remove the first subdomain
      else
        # Replace the first subdomain with the subdomain
        host_parts[0] = subdomain.value
      end
    else
      unless locale == default_locale
        # Add subdomain if there isn't one
        host_parts.unshift(subdomain.value)
      end
    end

    uri.host = host_parts.join(".")
    uri.to_s
  end

  def locale_switcher
    content = ""

    Locale.available_except_current.each do |locale|
      content += content_tag(:li, id: "locale_#{locale.id}", class: "nav-item") do
        locale_link(locale)
      end
    end

    content.html_safe
  end

  def locale_link(locale)
    link_to locale_url_for(locale), class: "nav-link" do
      content_tag(:i, "", class: "fa fa-language fa-fw me-2") + locale.name
    end
  end
end
