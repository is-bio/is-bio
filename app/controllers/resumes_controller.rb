class ResumesController < ApplicationController
  allow_unauthenticated_access

  layout "resume"

  def show
    @social_media_accounts = SocialMediaAccount.where.not(value: nil)
    @resume = Resume.first_or_initialize
  end
end
