class ApplicationController < ActionController::Base
  layout "application" # Should not remove it! Or will cause "Content Missing" issue using "turbo-frame".

  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale

  helper_method :default_locale?, :theme_file_name

  def raise_404(message = "Not Found")
    raise ActionController::RoutingError.new(message)
  end

  def default_locale?
    I18n.locale == I18n.default_locale
  end

  def current_locale
    if @current_locale.nil?
      @current_locale = Locale.find_by(key: I18n.locale)
      return @current_locale
    end

    @current_locale
  end

  def theme_file_name
    enabled_theme = Theme.enabled

    if enabled_theme.present?
      return "theme-#{enabled_theme.color}"
    end

    "theme-1"
  end

  private

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end
end
