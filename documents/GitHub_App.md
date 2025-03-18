# BlogOnRails GitHub App

If a user wants to automatically update his blog after executing the `git push` command, he/she needs to install the GitHub App first. Only in this way can GitHub push the `git push` events to this platform.
With the guidance of this article, you can create a GitHub App and require users to install it.

This article will assume that you are working on your local `Dev` env.

For `QA` or `Prodction` env, the situation are similar. You just need to change some value to meet your needs.

## New a GitHub App

Refer to [create-a-github-app](https://docs.github.com/en/developers/apps/setting-up-your-development-environment-to-create-a-github-app#step-2-register-a-new-github-app).

- Visit https://github.com/settings/apps , click `New GitHub App` button.
- Fill `GitHub App name` with `BlogOnRails dev`.
- Fill `desscription` with this:

	Install this app on your `markdown-blog` repository, so that when you `git push`, we will be notified and update your blog.

- Fill `Homepage URL`. This is for display purposes only and does not affect business logic.

### Install and run 'ngrok'

This paragraph is **only for local debugging** and is not necessary in a production environment.

Install `ngrok` and configure it well. Then do this:

```shell script
cd /path/to/BlogOnRails
rails server 3000

ngrok http http://localhost:3000 # You will get a base URL like: https://<a-subdomain-string-for-your-site>.ngrok-free.app
```

Add `config.hosts << "<a-subdomain-string-for-your-site>.ngrok-free.app"` to `config/environments/development.rb` and restart Rails server by stopping it first and then run `rails server 3000`.

### Webhook

- Check the `Active` checkbox.

- For `Webhook - Webhook URL`, fill `https://<a-subdomain-string-for-your-site>.ngrok-free.app/api/v1/github-events`.

    In production environment, you should fill `https://your-domain.com/api/v1/github-events`.

- For `Webhook - Secret`, you can run `ruby -rsecurerandom -e 'puts SecureRandom.hex(20)'` to generate one and use it.

### Continue setting for GitHub App

- For `Repository permissions`, choose `Access: Read-only` for `Contents`, `Metadata`.
- For `Subscribe to events`, choose `Push`.
- For `Where can this GitHub App be installed?`, choose `Any account`.
- Click `Create GitHub App`.

## Connect GitHub App to BlogOnRails

Visit https://your-domain.com/admin/github_app_settings , then

- Set `app_id` value with the `App ID` of your GitHub App.
- Set `public_link` value with the `Public link` of your GitHub App.

## Test blog syncing feature

- Visit https://github.com/RubyMarkdownBlog/markdown-blog/fork , fork it to your GitHub account.

- Visit https://your-domain.com/admin/settings , then set `github_username` value with your GitHub username. In this GitHub account, make sure there is a repository named `markdown-blog`.

- Now you can visit the `Public link` of your GitHub App.  
Then install this GitHub App on your `/<github_username>/markdown-blog` repository to test the blog syncing feature.

For example, make a small modification to a file in the `published` directory, then `git commit` and `git push`.

- Visit https://your-domain.com/ to see if the article is displayed successfully.

If not, you can go to the GitHub App settings page, click `Advanced`, and check `Recent Deliveries` to see if there is an error.

[//]: # (After the test is successful, you can invite more people to use the blog.)

Enjoy!
