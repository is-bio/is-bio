# Setting up your website

## Change profile avatar

To generate a suitable avatar, you can visit [GitHub profile settings](https://github.com/settings/profile) and click "Edit" to modify the avatar. Finally, save the GitHub avatar locally.

The avatar file on the server is `/srv/developer-portfolio-engine/app/assets/images/profile.jpg`.

Do not rename it, just replace it. You can replace it by running

```shell
scp /path/to/local/computer/profile.jpeg root@the_server_ip:/srv/developer-portfolio-engine/app/assets/images/profile.jpg
```

on your local computer. Then run

```shell
cd /srv/developer-portfolio-engine
rails assets:precompile
```

Then restart the "Rails web server" to make the changes take effect.

## Language and I18n

### Set "I18n.default_locale"

```shell
cd /srv/developer-portfolio-engine
vim config/initializers/locale.rb # Then restart the Rails web server to make the changes take effect.
```

- Currently, the website supports 8 major languages. The corresponding i18n files are in the `config/locales/` directory.
- If you want the website to display in other languages, you can translate `en.yml` into other languages, put it in `config/locales/`, and `vim config/initializers/locale.rb`.

## Modify the text content displayed on the website

```shell
cd /srv/developer-portfolio-engine
vim config/locales/en.yml # or other yml files, like: zh.yml
```

To make the changes take effect:
    1. Restart the "Rails web server".
    2. Restart the "Solid Queue" to handle background jobs.
