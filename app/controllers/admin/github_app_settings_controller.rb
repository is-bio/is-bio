class Admin::GithubAppSettingsController < Admin::BaseController
  before_action :set_github_app_setting, only: %i[ edit update ]

  def index
    @github_app_settings = GithubAppSetting.all
  end

  def edit
  end

  def update
    if @github_app_setting.update(github_app_setting_params)
      redirect_to admin_github_app_settings_path, notice: "GitHub App settings was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def set_github_app_setting
    @github_app_setting = GithubAppSetting.find(params.expect(:id))
  end

  def github_app_setting_params
    params.expect(github_app_setting: [ :key, :value ])
  end
end
