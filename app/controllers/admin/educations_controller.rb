class Admin::EducationsController < Admin::BaseController
  before_action :set_education, only: %i[ edit update destroy ]

  def index
    @educations = Education.all
  end

  def new
    @education = Education.new
  end

  def edit
  end

  def create
    @education = Education.new(education_params)
    @education.resume = Resume.first!

    if @education.save
      redirect_to admin_educations_path, notice: "Education was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @education.update(education_params)
      redirect_to admin_educations_path, notice: "Education was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @education.destroy!

    redirect_to admin_educations_path, status: :see_other, notice: "Education was successfully destroyed."
  end

private

  def set_education
    @education = Education.find(params.expect(:id))
  end

  def education_params
    params.expect(education: [ :school_name, :degree, :field_of_study, :start_year, :end_year ])
  end
end
