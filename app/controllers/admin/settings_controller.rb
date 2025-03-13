class Admin::SettingsController < Admin::BaseController
  def index
    @settings = Setting.all
  end
end
