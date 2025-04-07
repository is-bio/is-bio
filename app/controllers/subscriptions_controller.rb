class SubscriptionsController < ApplicationController
  allow_unauthenticated_access

  def create
    @subscriber = EmailSubscriber.new(subscription_params)

    if @subscriber.save
      # Send confirmation email
      SubscriptionsMailer.confirmation_email(@subscriber).deliver_later

      respond_to do |format|
        format.html do
          flash[:notice] = t("subscription.success.created")
          redirect_back(fallback_location: root_path)
        end
        format.json { render json: { status: "success", message: t("subscription.success.created") }, status: :created }
      end
    else
      respond_to do |format|
        format.html do
          flash[:alert] = @subscriber.errors.full_messages.to_sentence
          redirect_back(fallback_location: root_path)
        end
        format.json { render json: { status: "error", errors: @subscriber.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def confirm
    @subscriber = EmailSubscriber.find_by(token: params[:token])

    if @subscriber && @subscriber.confirm_subscription(params[:token])
      flash[:notice] = t("subscription.success.confirmed")
      redirect_to root_path
    else
      flash[:alert] = t("subscription.error.invalid_token")
      redirect_to root_path
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:email)
  end
end
