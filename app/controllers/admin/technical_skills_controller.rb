class Admin::TechnicalSkillsController < Admin::BaseController
  before_action :set_technical_skill, only: %i[ edit update destroy ]

  def index
    @technical_skills = TechnicalSkill.all
  end

  def new
    @technical_skill = TechnicalSkill.new
  end

  def edit
  end

  def create
    @technical_skill = TechnicalSkill.new(technical_skill_params)
    @technical_skill.resume = Resume.first!

    if @technical_skill.save
      redirect_to admin_technical_skills_path, notice: "Technical skill was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @technical_skill.update(technical_skill_params)
      redirect_to admin_technical_skills_path, notice: "Technical skill was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @technical_skill.destroy!

    redirect_to admin_technical_skills_path, status: :see_other, notice: "Technical skill was successfully destroyed."
  end

private

  def set_technical_skill
    @technical_skill = TechnicalSkill.find(params.expect(:id))
  end

  def technical_skill_params
    params.expect(technical_skill: [ :name ])
  end
end
