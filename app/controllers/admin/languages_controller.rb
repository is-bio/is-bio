class Admin::LanguagesController < Admin::BaseController
  before_action :set_language, only: %i[ edit update destroy ]

  def index
    @languages = Language.all
  end

  def new
    @language = Language.new
  end

  def edit
  end

  def create
    @language = Language.new(language_params)

    if @language.save
      redirect_to admin_languages_path, notice: "Language was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @language.update(language_params)
      redirect_to admin_languages_path, notice: "Language was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @language.destroy!

    redirect_to admin_languages_path, status: :see_other, notice: "Language was successfully destroyed."
  end

private

  def set_language
    @language = Language.find(params.expect(:id))
  end

  def language_params
    params.expect(language: [ :name, :proficiency ])
  end
end
