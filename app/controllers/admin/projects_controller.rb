class Admin::ProjectsController < Admin::BaseController
  before_action :set_project, only: %i[ edit update destroy ]

  def index
    @projects = Project.all.order(:id)
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to admin_projects_path, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to admin_projects_path, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy!

    redirect_to admin_projects_path, status: :see_other, notice: "Project was successfully destroyed."
  end

private

  def set_project
    @project = Project.find(params.expect(:id))
  end

  def project_params
    params.expect(project: [ :name, :summary, :description ])
  end
end
