module LocaleHelper
  def localed(path)
    if default_locale?
      path
    else
      "/#{I18n.locale}#{path}"
    end
  end

  def locale_switcher
    content = ""

    Locale.available_except_current.each do |locale|
      content += content_tag(:li, id: "locale_#{locale.id}", class: "nav-item") do
        localed_link(locale)
      end
    end

    content.html_safe
  end

  # Generates link to the current page but with the specified locale path prefix
  def localed_link(locale)
    # Use url_for with the target locale. Routes are scoped.
    target_path = url_for(locale: locale.key.to_sym == I18n.default_locale ? nil : locale.key)

    link_to target_path, class: "nav-link" do
      content_tag(:i, "", class: "fa fa-language fa-fw me-2") + locale.name
    end
  end
end
