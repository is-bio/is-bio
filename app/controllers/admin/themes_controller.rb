class Admin::ThemesController < Admin::BaseController
  def index
    @themes = Theme.order(:name).all
  end

  def edit
    @theme = Theme.find(params.require(:id))
  end

  def update
    @theme = Theme.find(params.require(:id))

    if @theme.update(theme_params)
      redirect_to admin_themes_path, notice: "Theme was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def theme_params
    params.require(:theme).permit(:color)
  end
end
