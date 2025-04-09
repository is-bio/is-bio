class Admin::EmailSubscribersController < Admin::BaseController
  def index
    @email_subscribers = EmailSubscriber.order(created_at: :desc).all
  end

  def new
    @email_subscriber = EmailSubscriber.new
  end

  def create
    @email_subscriber = EmailSubscriber.new(email_subscriber_params)

    if @email_subscriber.save
      redirect_to admin_email_subscribers_path, notice: "Email subscriber was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @email_subscriber = EmailSubscriber.find(params.expect(:id))

    if @email_subscriber.destroy
      redirect_to admin_email_subscribers_path, notice: "Email subscriber was successfully removed."
    else
      redirect_to admin_email_subscribers_path, alert: "Failed to remove email subscriber."
    end
  end

  private

  def email_subscriber_params
    params.expect(email_subscriber: [ :email, :confirmed ])
  end
end
