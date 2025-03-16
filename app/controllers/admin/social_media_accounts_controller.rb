class Admin::SocialMediaAccountsController < Admin::BaseController
  before_action :set_social_media_account, only: %i[ edit update ]

  def index
    @social_media_accounts = SocialMediaAccount.all
  end

  def edit
  end

  def update
    if @social_media_account.update(social_media_account_params)
      redirect_to admin_social_media_accounts_path, notice: "Social media account was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def set_social_media_account
      @social_media_account = SocialMediaAccount.find(params.expect(:id))
    end

    def social_media_account_params
      params.expect(social_media_account: [ :key, :value ])
    end
end
