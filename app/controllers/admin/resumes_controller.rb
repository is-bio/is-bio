class Admin::ResumesController < Admin::BaseController
  before_action :set_resume, only: %i[ edit update destroy ]

  def index
    @resumes = Resume.order(created_at: :desc).all
  end

  def new
    @resume = Resume.new
  end

  def create
    @resume = Resume.new(resume_params)

    if @resume.save
      redirect_to admin_resumes_path, notice: "Resume was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @resume.update(resume_params)
      redirect_to admin_resumes_path, notice: "Resume was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @resume.destroy
      redirect_to admin_resumes_path, notice: "Resume was successfully deleted."
    else
      redirect_to admin_resumes_path, alert: "Failed to delete resume."
    end
  rescue => exception
    redirect_to admin_resumes_path, alert: "Error deleting resume: #{exception.message}"
  end

  private

  def set_resume
    @resume = Resume.find(params.expect(:id))
  end

  def resume_params
    params.expect(resume: [ :title, :name, :position, :city, :phone_number, :email_address, :summary, :birth_date, :height, :weight ])
  end
end
