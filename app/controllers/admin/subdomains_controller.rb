class Admin::SubdomainsController < Admin::BaseController
  before_action :set_locales, only: %i[ new edit ]

  def index
    @subdomains = Subdomain.includes(:locale).order(:created_at).all
  end

  def new
    @subdomain = Subdomain.new
  end

  def create
    @subdomain = Subdomain.new(subdomain_params)

    if @subdomain.save
      redirect_to admin_subdomains_path, notice: "Subdomain was successfully created."
    else
      set_locales
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @subdomain = Subdomain.find(params.require(:id))
  end

  def update
    @subdomain = Subdomain.find(params.require(:id))

    if @subdomain.update(subdomain_params)
      redirect_to admin_subdomains_path, notice: "Subdomain was successfully updated."
    else
      set_locales
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subdomain = Subdomain.find(params.require(:id))

    if @subdomain.destroy
      redirect_to admin_subdomains_path, notice: "Subdomain was successfully deleted."
    else
      redirect_to admin_subdomains_path, alert: "Failed to delete subdomain."
    end
  rescue => e
    redirect_to admin_subdomains_path, alert: "Error deleting subdomain: #{e.message}"
  end

  private

  def set_locales
    @locales = Locale.order(:key).all
  end

  def subdomain_params
    params.require(:subdomain).permit(:value, :locale_id)
  end
end
