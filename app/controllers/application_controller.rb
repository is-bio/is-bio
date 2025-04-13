class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale

  def raise_404(message = "Not Found")
    raise ActionController::RoutingError.new(message)
  end

  private

  def switch_locale(&action)
    locale = extract_locale_from_subdomain || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  # Get locale code from request subdomain (like http://it.application.local:3000)
  # You have to put something like:
  #   127.0.0.1 it.application.local
  # in your /etc/hosts file to try this out locally
  #
  # Additionally, you need to add the following configuration to your config/environments/development.rb:
  #   config.hosts << 'it.application.local:3000'
  def extract_locale_from_subdomain
    subdomain = request.subdomains.first

    if subdomain.present?
      subdomain_record = Subdomain.find_by(value: subdomain)
      if subdomain_record.present?
        return subdomain_record.locale.key.to_sym
      end
    end

    nil
  end
end
