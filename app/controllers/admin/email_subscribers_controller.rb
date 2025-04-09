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

  def send_verification_email
    @email_subscriber = EmailSubscriber.find(params.expect(:id))

    if @email_subscriber.confirmed
      redirect_to admin_email_subscribers_path, alert: "Subscriber is already confirmed."
      return
    end

    @email_subscriber.generate_new_token if @email_subscriber.token.blank?

    if SubscriptionsMailer.confirmation_email(@email_subscriber).deliver_later
      redirect_to admin_email_subscribers_path, notice: "Verification email has been sent to #{@email_subscriber.email}."
    else
      redirect_to admin_email_subscribers_path, alert: "Failed to send verification email. Please check failed jobs in #{jobs_url} ."
    end
  end

  private

  def email_subscriber_params
    params.expect(email_subscriber: [ :email, :confirmed ])
  end
end
