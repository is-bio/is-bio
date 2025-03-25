class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def raise_404(message = "Not Found")
    raise ActionController::RoutingError.new(message)
  end
end
