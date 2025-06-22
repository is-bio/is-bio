class ResumesController < ApplicationController
  allow_unauthenticated_access

  layout "resume"

  def show
    @can_edit = params["view"] != "visitor" && authenticated?
    @social_media_accounts = SocialMediaAccount.where.not(value: nil).order(:id)
    @resume = Resume.first_or_initialize
    @technical_skills = TechnicalSkill.all.order(:id)
    @professional_skills = ProfessionalSkill.all.order(:id)
    @interests = Interest.all.order(:id)
    @languages = Language.all.order(:id)
  end
end
