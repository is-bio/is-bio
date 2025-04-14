class Admin::TranslationsController < Admin::BaseController
  before_action :set_post
  before_action :set_translation, only: %i[ edit update destroy ]
  before_action :set_available_locales, only: %i[ new edit ]

  def index
    @translations = @post.translations.includes(:locale).order("locales.id")
  end

  def new
    locale = Locale.find_by(key: I18n.locale)
    @translation = @post.translations.new(locale: locale)
  end

  def create
    @translation = @post.translations.new(translation_params)

    if @translation.save
      redirect_to admin_post_translations_path(@post), notice: "Translation was successfully created."
    else
      set_available_locales
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @translation.update(translation_params)
      redirect_to admin_post_translations_path(@post), notice: "Translation was successfully updated."
    else
      set_available_locales
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @translation.destroy
    redirect_to admin_post_translations_path(@post), notice: "Translation was successfully removed."
  rescue => e
    redirect_to admin_post_translations_path(@post), alert: "Error removing translation: #{e.message}"
  end

  private

  def set_post
    puts params.inspect
    @post = Post.find(params.expect(:post_id))
  end

  def set_translation
    @translation = @post.translations.find(params.expect(:id))
  end

  def set_available_locales
    existing_locale_ids = if @translation.nil?
      @post.translations.pluck(:locale_id)
    else
      @post.translations.where.not(id: @translation.id).pluck(:locale_id)
    end

    @available_locales = Locale.available_except_default.where.not(id: existing_locale_ids)
  end

  def translation_params
    params.require(:translation).permit(:locale_id, :title, :content)
  end
end
