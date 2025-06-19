class Admin::ProfessionalSkillsController < Admin::BaseController
  before_action :set_professional_skill, only: %i[ edit update destroy ]

  def index
    @professional_skills = ProfessionalSkill.all
  end

  def new
    @professional_skill = ProfessionalSkill.new
  end

  def edit
  end

  def create
    @professional_skill = ProfessionalSkill.new(professional_skill_params)

    if @professional_skill.save
      redirect_to admin_professional_skills_path, notice: "Professional skill was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @professional_skill.update(professional_skill_params)
      redirect_to admin_professional_skills_path, notice: "Professional skill was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @professional_skill.destroy!

    redirect_to admin_professional_skills_path, status: :see_other, notice: "Professional skill was successfully destroyed."
  end

private

  def set_professional_skill
    @professional_skill = ProfessionalSkill.find(params.expect(:id))
  end

  def professional_skill_params
    params.expect(professional_skill: [ :name ])
  end
end
