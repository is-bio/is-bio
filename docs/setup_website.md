# Setting up your website

## Change profile avatar

To generate a suitable avatar, you can visit [GitHub profile settings](https://github.com/settings/profile) and click "Edit" to modify the avatar. Finally, save the GitHub avatar locally.

The avatar file is `/srv/markdown-resume-blog/app/assets/images/profile.jpg`.

Do not rename it, just replace it. You can replace it by running

```shell
scp /path/to/local/computer/profile.jpeg root@the_server_ip:/srv/markdown-resume-blog/app/assets/images/profile.jpg
```

on your local computer. Then run

```shell
cd /srv/markdown-resume-blog
rails assets:precompile
```

Then restart the Rails web server.

## Language# Setting up your website

## Change profile avatar

To generate a suitable avatar, you can visit [GitHub profile settings](https://github.com/settings/profile) and click "Edit" to modify the avatar. Finally, save the GitHub avatar locally.

The avatar file is `/srv/markdown-resume-blog/app/assets/images/profile.jpg`.

Do not rename it, just replace it. You can replace it by running

```shell
scp /path/to/local/computer/profile.jpeg root@the_server_ip:/srv/markdown-resume-blog/app/assets/images/profile.jpg
```

on your local computer. Then run

```shell
cd /srv/markdown-resume-blog
rails assets:precompile
```

Then restart the Rails web server.

## Language and I18n

### Set "I18n.default_locale"

```shell
cd /srv/markdown-resume-blog
vim config/initializers/locale.rb # Then restart the Rails web server to make the changes take effect.
```

- Currently, the website supports two languages: English and Chinese. The corresponding i18n files are in the `config/locales/` directory.
- If you want the website to display in other languages, you can translate `en.yml` into other languages, put it in `config/locales/`, and `vim config/initializers/locale.rb`.
- Switching languages on the page is not currently supported.

## Modify the text content displayed on the website

```shell
cd /srv/markdown-resume-blog
vim config/locales/en.yml # or zh.yml
```

Then restart the Rails web server to make the changes take effect.
