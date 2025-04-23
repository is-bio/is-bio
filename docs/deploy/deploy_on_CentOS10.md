[中文文档](deploy_on_CentOS10_zh.md)

# developer-portfolio-engine website installation

This article is about how to install *developer-portfolio-engine* website on **CentOS 10 SELinux** (security-enhanced Linux).

## Apply for a domain name and add DNS A records

The following assumes that your domain name is *your-domain.com*. If you don't have a domain, you can just use `the_server_ip`.

Create two DNS A records:

1. Record 1
   - Record type: A
   - Name: *
   - IPv4 address: the_server_ip

2. Record 2
   - Record type: A
   - Name: @
   - IPv4 address: the_server_ip

Now you have to decide which server to install *developer-portfolio-engine* on.

If you have limited budget and already have an underutilized server, you can install *developer-portfolio-engine* on that server.

**Port 80 can be shared by multiple websites without conflicts.**

## Login to server via SSH

```shell
ssh root@the_server_ip
sudo passwd root # change password
```

## Install Ruby

```shell
yum install ruby
dnf install -y git
exit
```

## Install packages

```shell
yum install ruby-devel # Solve `bigdecimal` with native extensions issue

# Solve `psych` with native extensions failed issue.
curl -O https://rpmfind.net/linux/centos-stream/10-stream/CRB/x86_64/os/Packages/libyaml-devel-0.2.5-16.el10.x86_64.rpm
rpm -Uvh libyaml-devel-0.2.5-16.el10.x86_64.rpm
yum info libyaml-devel
```

## Clone project and install Ruby gems

```shell
cd /srv
git clone https://github.com/developer-portfolios/developer-portfolio-engine.git
cd /srv/developer-portfolio-engine
bundle install
```

## Set environment variables

```shell
# Set envs
echo 'export RAILS_ENV="production"' >> $HOME/.bashrc
exit

# Then use "ssh" to log in to the server again
echo $RAILS_ENV # check whether the environment variables have taken effect
```

## Set credentials

```shell
cd /srv/developer-portfolio-engine

# This file contains all the credentials that need to be set.
cat config/credentials.yml.example # Set "all" of them with the next command:

# After saving it, "config/credentials.yml.enc" and "config/master.key" will be created.
# In order for the modified credentials to take effect, you need to restart the Rails web server.
EDITOR="vim" bin/rails credentials:edit
```

**All** items shown in `config/credentials.yml.example` need to be set!

If you are still not sure how to set some items, you can use the default values in `config/credentials.yml.example` first, and then set the values correctly according to the relevant instructions when you find that the relevant functions do not work.

## Prepare SQLite database

```shell
cd /srv/developer-portfolio-engine
rails db:migrate # The database file is `./storage/development.sqlite3`. Running it has no side effects.
rails db:seed # Running it has no side effects.
```

## Install theme

Please follow [docs/install_theme.md](/docs/install_theme.md) to install it.

## Start or restart Rails web server

```shell
cd /srv/developer-portfolio-engine
rails assets:precompile # This needs to be executed whenever any assets are changed. Running it has no side effects.
pkill -F /var/run/blog.pid # Stop Rails web server. If you haven't started the Rails web server yet, you don't need to run it.
bundle exec puma -w 1 -e production # This is used to test if Rails web server can run well.
ctrl + c # If it has no error, press `ctrl + c` to terminate it. Then run:
# Start Rails web server, the `-w` parameter value here needs to be the same as the number of CPU cores of the server to maximize the web load. You can use `lscpu` to view it.
nohup bundle exec puma -w 1 -e production -b unix:///var/run/blog.sock --pidfile /var/run/blog.pid & 
tail -n 200 nohup.out # ./nohup.out is the log file
exit # When the ssh session is closed, the processes started during the session will also be terminated. So you should run `exit` in time to avoid the started processes being terminated.
```

## Firewall

```shell
firewall-cmd --state
firewall-cmd --get-active-zones
firewall-cmd --zone=public --list-ports
firewall-cmd --zone=public --list-services

# This step is critical.  
firewall-cmd --add-port=80/tcp
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```

## Configure Nginx

```shell
sudo su
dnf install -y nginx

# For `SELinux` only. To solve the problem https://stackoverflow.com/questions/23948527/13-permission-denied-while-connecting-to-upstreamnginx
# If you restarted the server, you have to run this two lines again!
setsebool -P httpd_can_network_connect 1
sudo setenforce 0

cd /etc/nginx
cp /srv/developer-portfolio-engine/docs/deploy/nginx.conf ./ # Replace the existing file
cd /etc/nginx/conf.d
cp /srv/developer-portfolio-engine/docs/deploy/default_server.conf ./
cp /srv/developer-portfolio-engine/docs/deploy/blog_nginx.conf ./
vim blog_nginx.conf # Replace the "your-domain.com" with your actual domain name.

nginx -t # Check whether the configuration is correct.
systemctl enable nginx # Set to start automatically at boot
systemctl start nginx
```

Visit http://your-domain.com, you should see that the web works well.

## Troubleshooting

1. Always make sure that the Rails web server is running!

    ```shell
    ps -ef|grep puma # You should see the process running. If you didn't see any process listed, you should start Rails web server.
    bundle exec puma -w 1 -e production # This is used to test if Rails web server can run well. If it has no error, then `ctrl + c` to terminate it. Then run:
    # Start Rails web server.
    nohup bundle exec puma -w 1 -e production -b unix:///var/run/blog.sock --pidfile /var/run/blog.pid &
    tail -n 200 nohup.out # ./nohup.out is the log file
    exit # When the ssh session (connection) is closed, the processes started during the session will also be terminated. So you should run `exit` in time to avoid the started processes being terminated.
    ```

2. Always make sure that nginx is running!

    ```shell
    ps -ef|grep nginx # You should see the process running. If you didn't see any process listed, you should start nginx.
    nginx -t # Check whether the configuration is correct.
    systemctl reload nginx.service # Reload nginx with no downtime.
    systemctl restart nginx # Make sure there is no error. If there is an error, fix it by reading the error message.
    exit # When the ssh session (connection) is closed, the processes started during the session will also be terminated. So you should run `exit` in time to avoid the started processes being terminated.
    ```

    - Check nginx errors by:

        ```shell
        tail -n 200 /var/log/nginx/error.log
        > /var/log/nginx/error.log # clear it
        
        cat /var/log/audit/audit.log | grep nginx | grep denied
        > /var/log/audit/audit.log # clear it
        ```

3. If the status code of `assets` (js, css, images, etc.) is *404*.
    - **Clear your browser cache** and refresh the page again.

### If you have restarted the server machine

These steps need to be done again.

```shell
setsebool -P httpd_can_network_connect 1
sudo setenforce 0
systemctl restart nginx
```

## Create the Admin User

```shell
cd /srv/developer-portfolio-engine
vim db/seeds.rb
```

Uncomment the first few lines of code to create the Admin User.

```shell
rails db:seed
git restore db/seeds.rb
```

Use this email address and password to log in on http://your-domain.com/admin.

## Send email via SMTP

Please follow the instructions in [docs/send_email_via_smtp_guide.md](/docs/send_email_via_smtp_guide.md) to complete this step.

## Start "Solid Queue" to handle background jobs

Blog posts, images, files synchronization, sending emails, generating thumbnails, etc. all require background tasks to be started!

```shell
cd /srv/developer-portfolio-engine
# If there is content output on the screen, it means that some asset files has been rewritten.
#   You need to restart Rails web server for the changes to take effect.
rails assets:precompile

bin/jobs # This is used to test if background tasks can run well.
ctrl + c # If it has no error, press `ctrl + c` to terminate it. Then run:
nohup bin/jobs & # Start it. "/nohup.out" is the log file
exit # When the ssh session is closed, the processes started during the session will also be terminated. So you should run `exit` in time to avoid the started processes being terminated.
```

- First, use email address and password to log in on http://your-domain.com/admin.
- Second, use this username and password to log in on http://your-domain.com/jobs to see if there are failed tasks.
    - The username and password can be obtained by running `EDITOR="vim" bin/rails credentials:edit`.

### Restart "Solid Queue" to handle background jobs

When the code related to the background task is changed, you need to restart "Solid Queue" for the changes to take effect.

```shell
ps -ef|grep solid
kill -9 the_solid-queue-supervisor_pid
ps -ef|grep solid # Verify that there are no related processes listed.
nohup bin/jobs & # Start it. "/nohup.out" is the log file.
ps -ef|grep solid # Confirm that it is started.
exit # When the ssh session is closed, the processes started during the session will also be terminated. So you should run `exit` in time to avoid the started processes being terminated.
```

### Troubleshooting

Important source code may have been modified, causing problems with background task processing. **Restart** `Solid Queue` and see.

```shell
# You should see the process running. If you didn't see any process listed,
#   you should start it by reading the instructions above.
ps -ef|grep solid
```

## Create and install your "GitHub App" to sync "markdown-blog" repository's files' changes to your blog website

Please read [markdown-blog](https://github.com/developer-portfolios/markdown-blog) if you are not familiar with how to write a blog using Markdown and Git.

Please follow the instructions in [GitHub_App.md](/docs/GitHub_App.md) to complete this step.

## Automatically generate thumbnails for images

We use [ImageMagick](https://imagemagick.org/) to generate thumbnails for images.

```shell
cd /usr/local/sbin
curl -O https://imagemagick.org/archive/binaries/magick
chmod 755 magick
exit 

magick -version # To test if it has been installed successfully.
```

## Support "https" for web

### Way 1: Use a third-party service such as CloudFlare. Large domain name service providers generally provide this service for free (Recommended)

This is the most convenient way.

If you use CloudFlare SSL/TLS encryption default mode `Flexible`, you can see "https" has already been supported.

You can visit https://your-domain.com to check it.

### Way 2: Implement support for "https" yourself

Please read [enable_https](/docs/deploy/enable_https.md).

## Redirections

In CloudFlare dashboard, click `Rules`.

### Redirect http:// to https://

- `Rule templates` > Choose template `Redirect from HTTP to HTTPS` > `Create a Rule`.
- Don't need to change anything, just click `Deploy`.

### Redirect www.your-domain.com to your-domain.com

- `Rule templates` > Choose template `Redirect from WWW to Root` > `Create a Rule`.
- Don't need to change anything, just click `Deploy`.

## Setting up your website

Read [setup_website.md](/docs/setup_website.md).

## How to upgrade the website to the latest version.

```shell
pkill -F /var/run/blog.pid # Stop Rails web server
# The next two lines are another way to stop Rails web server
#ps -ef | grep puma # You will get a pid which is the same as `cat /var/run/blog.pid`.
#kill -9 the_master_pid # Some workers processes are started by master process, you can kill the master pid.

cd /srv/developer-portfolio-engine
git stash
git pull origin main
git stash apply
bundle install
rails db:migrate # You can skip this step if no new migration files added. Running it has no side effects. 
rails db:seed # You can skip this step if `db/seeds.rb` is not changed. Running it has no side effects.
rails assets:precompile # This needs to be executed whenever any assets are changed.
```

- Then follow the `## Start or restart Rails web server` section to restart Rails web server.
- Follow the `### Restart "Solid Queue" to handle background jobs` section to restart "Solid Queue".

## Database backup

```shell
# Run it in your local computer
scp root@the_server_ip:/srv/developer-portfolio-engine/storage/production.sqlite3 ./
```
