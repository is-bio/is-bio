class SubscriptionsMailer < ApplicationMailer
  def confirmation_email(email_subscriber)
    @email_subscriber = email_subscriber
    @confirmation_url = confirm_subscription_url(token: email_subscriber.token)

    mail(
      to: email_subscriber.email,
      subject: I18n.t("subscription.confirmation.subject")
    )
  end
end
