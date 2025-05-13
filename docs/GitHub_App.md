# personal-brand-website-builder GitHub App

If you want to automatically update your blog after executing the `git push` command, you need to install your GitHub App first. Only in this way can GitHub push the `git push` events to this platform.
With the guidance of this article, you can create a GitHub App for you to install it.

This article will assume that you are working on your local `development` env.
In the development environment, https://your-domain.com (should be replaced with your real domain) below actually refers to http://localhost:3000.

For `qa` or `prodction` env, the situation are similar. You just need to change some value to meet your needs.

## Create your GitHub App

Refer to [create-a-github-app](https://docs.github.com/en/developers/apps/setting-up-your-development-environment-to-create-a-github-app#step-2-register-a-new-github-app).

- Visit https://github.com/settings/apps , click `New GitHub App` button.
- Fill `GitHub App name` with `Your Name's Blog dev` (or any name you like).
- Fill `Homepage URL`. This is for display purposes only and does not affect business logic. E.g., https://your-domain.com.

### Install and run 'ngrok' (development environment only)

This paragraph is **only for development environment debugging** and is not necessary in a production environment!

Install `ngrok` and configure it well. Then do this:

```shell
cd /path/to/personal-brand-website-builder
ngrok http http://localhost:3000 # You will get a base URL like: https://<a-subdomain-string-for-your-site>.ngrok-free.app
```

Add `config.hosts << "<a-subdomain-string-for-your-site>.ngrok-free.app"` to `config/environments/development.rb` and run `rails server 3000`.

### Webhook

- Check the `Active` checkbox (already done by default).

- For `Webhook - Webhook URL`, fill `https://<a-subdomain-string-for-your-site>.ngrok-free.app/api/v1/github-events`.

    In production environment, you should fill `https://your-domain.com/api/v1/github-events`.

- For `Webhook - Secret`, you enter a random string.

### Continue setting for your GitHub App

- Unfold `Repository permissions`, then choose `Access: Read-only` for `Contents` and `Metadata`.
- For `Subscribe to events`, choose `Push`.
- For `Where can this GitHub App be installed?`, choose `Any account` or `Only on this account`.
- Click `Create GitHub App`.

## Connect your GitHub App to personal-brand-website-builder

Visit https://your-domain.com/admin/github_app_settings , then

- Set `app_id` value with the `App ID` of your GitHub App.
- Set `public_link` value with the `Public link` of your GitHub App (not required).
    - If your GitHub App is private (Only allow this GitHub App to be installed on your own GitHub account), you don't need to enter it.
    - An example of `public_link`: https://github.com/apps/your-awesome-example-app

## Start "Solid Queue" to handle background jobs (Must Do)

Blog posts, images, files synchronization, sending emails, generating thumbnails, etc. all require background tasks to be started!

Please read relevant content of [README.md](/README.md) or [deploy_on_CentOS10.md](/docs/deploy/deploy_on_CentOS10.md) to start it.

## Test posts (Markdown files) synchronization feature

### Fork `markdown-blog` repository and set `github_username`

- Visit https://github.com/PersonalBranding/markdown-blog/fork , fork it to your GitHub account.

- Visit https://your-domain.com/admin/settings , then set `github_username` value with your GitHub username (or organization name). In this GitHub account, make sure there is a repository named `markdown-blog`.

### Install your GitHub App to `markdown-blog` repository

- Visit the `Public link` of your GitHub App. An example of `Public link`: https://github.com/apps/your-awesome-example-app
- Click `Install`.
- Choose `Only select repositories` and select `<github_username>/markdown-blog` repository to test the blog syncing feature.

### Change a markdown file to test synchronization feature

For example, make a copy of `README.md` in the directory `/published` and make some changes to the file. Then `git commit` and `git push`.

- Visit https://your-domain.com/ to see if the article is displayed successfully. You should see your **first post** published on your blog site.

### Troubleshooting

If not, you can go to your GitHub App settings page (e.g., https://github.com/settings/apps/your-awesome-example-app) , click `Advanced`, and check `Recent Deliveries` to see if there is an error.

If there is an error, click on it to view the specific error information.

You can click `Redeliver` to send this request again. Or you can make another commit and `git push` to send a new request.

### Test the image synchronization and thumbnail automatic generation features

You noticed that the thumbnail of the first post was not displaying correctly, so let's fix that.

- Rename the `/images/example_1.jpg` in `markdown-blog` repository to `/images/example_2.jpg`
- Then in your *first post* you have just created, set `thumbnail: example_2.jpg`.
- `git commit` and `git push`.
- Refresh https://your-domain.com/. You should see the thumbnail.

### Test the file synchronization

- Rename `/files/empty_example.pdf` to `/files/empty_example_2.pdf`.
- Then open your *first post* markdown file, add the below to the contents:

    ```
    [empty example PDF 2](/files/empty_example_2.pdf)

    ![example_2.jpg](/images/example_2.jpg)

    ![example_2.jpg](../images/example_2.jpg)
    ```
- `git commit` and `git push`.
- Click on the link to the first post, and you should see the pdf and the two images appear correctly. 

#### The image was modified, but it did not refresh on the page.

- You can check the file modification time and size under `/srv/personal-brand-website-builder/public/images`. If there is no problem, it is the image cache problem.
- Clear your browser's cache.
- If you use a CDN service such as CloudFlare, you also need to manually clear the CDN cache.

Enjoy blogging with *Markdown* and *Git*!
