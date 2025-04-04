class SubscriptionsController < ApplicationController
  allow_unauthenticated_access

  def create
    @subscriber = EmailSubscriber.new(subscription_params)

    if @subscriber.save
      # TODO: Send confirmation email (implementation would be required in a real app)
      # SubscriptionMailer.confirmation_email(@subscriber).deliver_later

      respond_to do |format|
        format.html do
          flash[:success] = "Please check your email to confirm your subscription."
          redirect_back(fallback_location: root_path)
        end
        format.json { render json: { status: "success", message: "Please check your email to confirm your subscription." }, status: :created }
      end
    else
      respond_to do |format|
        format.html do
          flash[:error] = @subscriber.errors.full_messages.to_sentence
          redirect_back(fallback_location: root_path)
        end
        format.json { render json: { status: "error", errors: @subscriber.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def confirm
    @subscriber = EmailSubscriber.find_by(token: params[:token])

    if @subscriber && @subscriber.confirm_subscription(params[:token])
      flash[:success] = "Your subscription has been confirmed. Thank you for subscribing!"
      redirect_to root_path
    else
      flash[:error] = "Invalid or expired confirmation link."
      redirect_to root_path
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:email)
  end
end
