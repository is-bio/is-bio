class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.config.action_mailer.default_options&.dig(:from) || "from@example.com",
          reply_to: Rails.application.config.action_mailer.default_options&.dig(:reply_to) ||
            Rails.application.credentials.dig(:smtp, :user_name) || "noreply@example.com"

  layout "mailer"
end
