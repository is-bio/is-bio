# Send Email via SMTP

In the email scenario, in this system, the user enters the email address to subscribe, and the system sends a subscription confirmation email to the user. The user completes the subscription after clicking the confirmation email. This function has been completed, and you only need to configure it as described below.

This article takes "Gmail SMTP Server" as an example, and the configuration of other email servers is similar.

When there is an article update, a push email should be sent to the subscribed users, but this function is still under development.

## Prerequisites

- A Google Account
- "2-Step Verification" enabled on your Google Account

## Creating an App Password in Google Account

1. Sign in to your Google Account
    - Go to [Google Account Security Settings](https://myaccount.google.com/security)

2. Turn on "2-Step Verification"

3. Create an "App Password"
    - Visit https://myaccount.google.com/apppasswords
    - Enter a name for your app (e.g., "Developer Portfolio")
    - Click "Create"
    - Google will display a password. **Copy this password immediately** as it will only be shown once. I will refer to it as `your-smtp-password` later.

## Setup Rails credentials and environment variables

## Verifying Your Configuration

Your application is configured to use Gmail SMTP in both development and production environments:

### Development Configuration

In `config/environments/development.rb`, the SMTP settings are configured as:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  user_name: Rails.application.credentials.dig(:smtp, :user_name),
  password: Rails.application.credentials.dig(:smtp, :password),
  address: ENV.fetch("SMTP_ADDRESS", "smtp.gmail.com"),
  port: 587,
  domain: "localhost",
  authentication: :plain,
  enable_starttls_auto: true
}
```

### Production Configuration

In `config/environments/production.rb`, the SMTP settings use credentials management:

```ruby
config.action_mailer.smtp_settings = {
  user_name: Rails.application.credentials.dig(:smtp, :user_name),
  password: Rails.application.credentials.dig(:smtp, :password),
  address: ENV.fetch("SMTP_ADDRESS", "smtp.gmail.com"),
  port: 587,
  domain: ENV['APPLICATION_HOST'],
  authentication: :plain,
  enable_starttls_auto: true
}
```

### Setup Rails credentials

```shell
cd /path/to/developer-portfolio-engine
EDITOR="vim" bin/rails credentials:edit
```

```
smtp:
  user_name: your.email@gmail.com
  password: your-smtp-password
```

### Setting Environment Variables

1. `APPLICATION_HOST` (only for *production* environment)
    - Set this to your application's domain name (e.g., `your-domain.com`)
    - This is used to generate correct URLs in emails

2. `SMTP_ADDRESS` (Only if you are **not** using *Gmail SMTP Server*, you need to set it up.)

Example:

```shell
# Set envs in CentOS 10. If you are using other operating systems, please search for how to set it yourself
echo 'export APPLICATION_HOST="your-domain.com"' >> $HOME/.bashrc # replace the "your-domain.com"
echo 'export SMTP_ADDRESS="smtp.serveraddress.com"' >> $HOME/.bashrc # if you are not using Gmail SMTP Server
exit # Use ssh to log in to the server again to check whether the environment variables have taken effect
echo $APPLICATION_HOST
```

## Testing Email Delivery

1. Please read [deploy_on_CentOS10.md](/docs/deploy/deploy_on_CentOS10.md) to restart Rails web server.
2. Please read [deploy_on_CentOS10.md](/docs/deploy/deploy_on_CentOS10.md) to start (or restart) "Solid Queue" process to handle background jobs.
3. Email the Admin User.
    - Visit http://your-domain.com/admin.
    - Click "Forgot password?" link.
    - Enter the Admin User's email and click the button bellow.
4. Log in http://your-domain.com/admin as the Admin User.
5. Visit http://your-domain.com/jobs to see if there are failed jobs.
    - If there are failed jobs, read the "Error information" to fix the error.
6. Verify that the password recovery email is received.
