class Admin::LocalesController < Admin::BaseController
  def index
    @locales = Locale.order(:key).all
  end

  def new
    @locale = Locale.new
  end

  def create
    @locale = Locale.new(locale_params)

    if @locale.save
      redirect_to admin_locales_path, notice: "Locale was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @locale = Locale.find(params.expect(:id))
  end

  def update
    @locale = Locale.find(params.expect(:id))

    if @locale.update(locale_params)
      redirect_to admin_locales_path, notice: "Locale was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @locale = Locale.find(params.expect(:id))

    if @locale.destroy
      redirect_to admin_locales_path, notice: "Locale was successfully deleted."
    else
      redirect_to admin_locales_path, alert: "Failed to delete locale."
    end
  end

  private

  def locale_params
    params.expect(locale: [ :key, :english_name, :name ])
  end
end
