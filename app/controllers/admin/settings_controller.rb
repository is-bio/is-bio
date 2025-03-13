class Admin::SettingsController < Admin::BaseController
  before_action :set_setting, only: %i[ edit update ]

  def index
    @settings = Setting.all
  end

  def edit
  end

  def update
    if @setting.update(setting_params)
      redirect_to admin_settings_path, notice: "Setting was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def set_setting
      @setting = Setting.find(params.expect(:id))
    end

    def setting_params
      params.expect(setting: [ :key, :value ])
    end
end
