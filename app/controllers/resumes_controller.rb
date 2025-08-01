class ResumesController < ApplicationController
  allow_unauthenticated_access

  layout "resume"

  def show
    @resume = Resume.first_or_initialize

    if @resume.new_record? && authenticated?
      redirect_to admin_resumes_path
    end

    @can_edit = params["view"] != "visitor" && authenticated?
    @social_media_accounts = SocialMediaAccount.where.not(value: nil).order(:id)
    @technical_skills = TechnicalSkill.all.order(:id)
    @professional_skills = ProfessionalSkill.all.order(:id)
    @interests = Interest.all.order(:id)
    @languages = Language.all.order(:id)
    @educations = Education.all.order(end_year: :desc)
    @experiences = Experience.all.order(start_year: :desc, start_month: :desc)
    @projects = Project.all.order(:id)
  end
end
