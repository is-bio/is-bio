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
    - Enter a name for your app (e.g., "Resume Blog")
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
cd /path/to/markdown-resume-blog
EDITOR="vim" bin/rails credentials:edit
```

```
smtp:
  user_name: your.email@gmail.com
  password: your-smtp-password
```

### Setting Environment Variables

1. `APPLICATION_HOST` (only for *production* environment)
    - Set this to your application's domain name (e.g., `blog.your-site.com`)
    - This is used to generate correct URLs in emails

2. `SMTP_ADDRESS` (Only if you are not using *Gmail SMTP Server*, you need to set it up.)

Example:

```shell
# Set envs in CentOS 10. If you are using other operating systems, please search for how to set it yourself
echo 'export APPLICATION_HOST="blog.your-site.com"' >> $HOME/.bashrc
echo 'export SMTP_ADDRESS="smtp.serveraddress.com"' >> $HOME/.bashrc
exit # Use ssh to log in to the server again to check whether the environment variables have taken effect
echo $APPLICATION_HOST
```

## Testing Email Delivery

After setting up environment variables, you can test email delivery:

1. Start your Rails server
2. Start Solid Queue to handle background job: run `bin/jobs`
3. Create a new subscription through the application form
4. Check the Rails logs for mail delivery status
5. Verify that the confirmation email is received

## Troubleshooting

TODO: use the Solid Queue job web portal.

### Common Issues and Solutions

1. **"Authentication failed" errors**
    - Verify your App Password is correct and hasn't expired
    - Ensure you're using the App Password, not your regular Google password
    - Check if you've properly set the environment variables

2. **"Hostname not allowed" errors**
    - Make sure you have properly set the `domain` in SMTP settings
    - In development, use "localhost" as the domain

3. **"Connection timed out" errors**
    - Check your network settings and firewall
    - Some networks block outgoing SMTP traffic on port 587

4. **No emails being sent**
    - Verify `config.action_mailer.perform_deliveries = true` is set
    - Check if ActionMailer is being used correctly in controllers

5. **Invalid recipient address errors**
    - Ensure email addresses are valid format
    - Some email addresses may be rejected by Gmail's filters

### Debugging Tips

1. Set `config.action_mailer.raise_delivery_errors = true` (already done)
2. Monitor your Rails logs for detailed error messages
3. Use a test mail delivery service like MailCatcher for local development
4. Check your Gmail account's activity to see if sending attempts are recorded

## Security Considerations and Best Practices

1. **Never commit credentials to version control**
    - Use environment variables or Rails credentials
    - Include `.env` files in your `.gitignore`

2. **Regularly rotate your App Passwords**
    - Delete old App Passwords and create new ones periodically
    - Update your environment variables when you rotate passwords

3. **Limit permissions**
    - Use a dedicated Gmail account for your application
    - Consider using a Google Workspace account for business applications

4. **Rate limits**
    - Be aware that Gmail has sending limits (typically 500 emails per day for regular accounts)
    - Implement queuing for bulk emails to avoid rate limiting

5. **Monitor for unauthorized use**
    - Regularly check your Gmail account's activity for suspicious behavior
    - Set up alerts for unusual sending patterns

6. **CAN-SPAM compliance**
    - Include a physical address in your emails
    - Provide unsubscribe links in all marketing emails
    - Honor unsubscribe requests promptly

7. **For production use**
    - Consider using a dedicated email service like SendGrid, Mailgun, or Amazon SES
    - These services offer better deliverability, analytics, and higher sending limits

## Additional Resources

- [Google Account Help: Sign in with App Passwords](https://support.google.com/accounts/answer/185833)
- [Rails ActionMailer Documentation](https://guides.rubyonrails.org/action_mailer_basics.html)
- [Email Deliverability Best Practices](https://www.sparkpost.com/resources/email-deliverability-guide/)
