class Admin::BaseController < ApplicationController
  layout "admin"

  skip_around_action :switch_locale
end
