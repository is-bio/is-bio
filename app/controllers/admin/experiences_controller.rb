class Admin::ExperiencesController < Admin::BaseController
  before_action :set_experience, only: %i[ edit update destroy ]

  def index
    @experiences = Experience.all.order(start_year: :desc, start_month: :desc)
  end

  def new
    @experience = Experience.new
  end

  def edit
  end

  def create
    @experience = Experience.new(experience_params)
    @experience.resume = Resume.first!

    if @experience.save
      redirect_to admin_experiences_path, notice: "Experience was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @experience.update(experience_params)
      redirect_to admin_experiences_path, notice: "Experience was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @experience.destroy!

    redirect_to admin_experiences_path, status: :see_other, notice: "Experience was successfully destroyed."
  end

private

  def set_experience
    @experience = Experience.find(params.expect(:id))
  end

  def experience_params
    params.expect(experience: [ :company_name, :title, :description, :start_year, :start_month, :end_year, :end_month ])
  end
end
