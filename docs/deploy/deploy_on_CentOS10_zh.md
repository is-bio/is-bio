[English document](deploy_on_CentOS10.md)

# 搭建基于 developer-portfolio-engine 的网站

本文介绍如何在 **CentOS 10 SELinux**（安全增强型 Linux）上安装 *developer-portfolio-engine* 网站。

## 申请域名并添加 DNS A 记录

以下假设您的域名是 *your-domain.com*。如果您没有域名，可以使用 `服务器IP`。

创建两条 DNS A 记录：

1. 记录 1
    - 记录类型：A
    - 名称：*
    - IPv4 地址：服务器IP

2. 记录 2
    - 记录类型：A
    - 名称：@
    - IPv4 地址：服务器IP

现在您需要决定在哪台服务器上安装 *developer-portfolio-engine*。

如果您的预算有限，并且已经有一台未充分利用的服务器，则可以将 *developer-portfolio-engine* 安装在该服务器上。

**端口 80 可以由多个网站共享而不会产生冲突。**

## 通过 SSH 登录服务器

```shell
ssh root@服务器IP
sudo passwd root # 更改密码
```

## 安装 Ruby

```shell
yum install ruby
dnf install -y git
exit
```

## 安装软件包

```shell
yum install ruby-devel # 解决 `bigdecimal` 带有原生扩展的问题

# 解决 `psych` 带有原生扩展失败的问题。
curl -O https://rpmfind.net/linux/centos-stream/10-stream/CRB/x86_64/os/Packages/libyaml-devel-0.2.5-16.el10.x86_64.rpm
rpm -Uvh libyaml-devel-0.2.5-16.el10.x86_64.rpm
yum info libyaml-devel
```

## 克隆项目并安装 Ruby gems

```shell
cd /srv
git clone https://github.com/developer-portfolios/developer-portfolio-engine.git
cd /srv/developer-portfolio-engine
bundle install
```

## 设置环境变量

```shell
# 设置环境变量
echo 'export RAILS_ENV="production"' >> $HOME/.bashrc
exit

# 然后再次使用 "ssh" 登录服务器
echo $RAILS_ENV # 检查环境变量是否已生效
```

## 设置credentials

```shell
cd /srv/developer-portfolio-engine

# 此文件包含所有需要设置的credentials。
cat config/credentials.yml.example # 使用下一个命令设置“所有”credentials：

# 保存后，将创建 "config/credentials.yml.enc" 和 "config/master.key"。
# 为了使修改后的credentials生效，您需要重新启动 Rails Web 服务器。
EDITOR="vim" bin/rails credentials:edit
```

**所有** `config/credentials.yml.example` 中显示的项目都需要设置！

如果您仍然不确定如何设置某些项目，可以先使用 `config/credentials.yml.example` 中的默认值，然后在发现相关功能不起作用时，根据相关说明正确设置值。

## 准备 SQLite 数据库

```shell
cd /srv/developer-portfolio-engine
rails db:migrate # 数据库文件是 `./storage/development.sqlite3`。运行它没有副作用。
rails db:seed # 运行它没有副作用。
```

## 安装主题

请按照 [docs/install_theme.md](/docs/install_theme.md) 进行安装。

## 启动或重启 Rails Web 服务器

```shell
cd /srv/developer-portfolio-engine
rails assets:precompile # 每当任何资源发生更改时都需要执行此操作。运行它没有副作用。
pkill -F /var/run/blog.pid # 停止 Rails Web 服务器。如果尚未启动 Rails Web 服务器，则无需运行此命令。
bundle exec puma -w 1 -e production # 用于测试 Rails Web 服务器是否可以正常运行。
ctrl + c # 如果没有错误，按 `ctrl + c` 终止它。然后运行：
# 启动 Rails Web 服务器，这里的 `-w` 参数值需要与服务器的 CPU 核心数相同以最大化 Web 负载。您可以使用 `lscpu` 查看。
nohup bundle exec puma -w 1 -e production -b unix:///var/run/blog.sock --pidfile /var/run/blog.pid &
tail -n 200 nohup.out # ./nohup.out 是日志文件
exit # 当 ssh 会话关闭时，会话期间启动的进程也将被终止。因此，您应该及时运行 `exit` 以避免启动的进程被终止。
```

## 防火墙

```shell
firewall-cmd --state
firewall-cmd --get-active-zones
firewall-cmd --zone=public --list-ports
firewall-cmd --zone=public --list-services

# 这一步至关重要。
firewall-cmd --add-port=80/tcp
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```

## 配置 Nginx

```shell
sudo su
dnf install -y nginx

# 仅适用于 `SELinux`。解决 https://stackoverflow.com/questions/23948527/13-permission-denied-while-connecting-to-upstreamnginx 问题
# 如果您重启了服务器，则必须再次运行这两行！
setsebool -P httpd_can_network_connect 1
sudo setenforce 0

cd /etc/nginx
cp /srv/developer-portfolio-engine/docs/deploy/nginx.conf ./ # 替换现有文件
cd /etc/nginx/conf.d
cp /srv/developer-portfolio-engine/docs/deploy/blog_nginx.conf ./
vim blog_nginx.conf # 将 "your-domain.com" 替换为您的实际域名。

nginx -t # 检查配置是否正确。
systemctl enable nginx # 设置开机自启动
systemctl start nginx
```

访问 http://your-domain.com，您应该看到 Web 正常工作。

## 故障排除

1. 始终确保 Rails Web 服务器正在运行！

    ```shell
    ps -ef|grep puma # 您应该看到进程正在运行。如果您没有看到任何进程列出，则应启动 Rails Web 服务器。
    bundle exec puma -w 1 -e production # 用于测试 Rails Web 服务器是否可以正常运行。如果没有错误，则按 `ctrl + c` 终止它。然后运行：
    # 启动 Rails Web 服务器。
    nohup bundle exec puma -w 1 -e production -b unix:///var/run/blog.sock --pidfile /var/run/blog.pid &
    tail -n 200 nohup.out # ./nohup.out 是日志文件
    exit # 当 ssh 会话（连接）关闭时，会话期间启动的进程也将被终止。因此，您应该及时运行 `exit` 以避免启动的进程被终止。
    ```

2. 始终确保 nginx 正在运行！

    ```shell
    ps -ef|grep nginx # 您应该看到进程正在运行。如果您没有看到任何进程列出，则应启动 nginx。
    nginx -t # 检查配置是否正确。
    systemctl reload nginx.service # 无需停机重新加载 nginx。
    systemctl restart nginx # 确保没有错误。如果有错误，请通过阅读错误消息来修复它。
    exit # 当 ssh 会话（连接）关闭时，会话期间启动的进程也将被终止。因此，您应该及时运行 `exit` 以避免启动的进程被终止。
    ```

    - 通过以下方式检查 nginx 错误：

        ```shell
        tail -n 200 /var/log/nginx/error.log
        > /var/log/nginx/error.log # 清空它

        cat /var/log/audit/audit.log | grep nginx | grep denied
        > /var/log/audit/audit.log # 清空它
        ```

3. 如果 `assets`（js、css、图片等）的状态码为 *404*。
    - **清除浏览器缓存**并再次刷新页面。

### 如果您重新启动了服务器机器

这些步骤需要再次完成。

```shell
setsebool -P httpd_can_network_connect 1
sudo setenforce 0
systemctl restart nginx
```

## 创建管理员用户

```shell
cd /srv/developer-portfolio-engine
vim db/seeds.rb
```

取消注释代码的前几行以创建管理员用户。

```shell
rails db:seed
git restore db/seeds.rb
```

使用此电子邮件地址和密码登录 http://your-domain.com/admin。

## 通过 SMTP 发送电子邮件

请按照 [docs/send_email_via_smtp_guide.md](/docs/send_email_via_smtp_guide.md) 中的说明完成此步骤。

## 启动 "Solid Queue" 处理后台任务

博客文章、图片、文件同步、发送电子邮件、生成缩略图等都需要启动后台任务！

```shell
cd /srv/developer-portfolio-engine
# 如果屏幕上有内容输出，则表示某些资源文件已被重写。
#   您需要重新启动 Rails Web 服务器才能使更改生效。
rails assets:precompile

bin/jobs # 用于测试后台任务是否可以正常运行。
ctrl + c # 如果没有错误，按 `ctrl + c` 终止它。然后运行：
nohup bin/jobs & # 启动它。“/nohup.out”是日志文件
exit # 当 ssh 会话关闭时，会话期间启动的进程也将被终止。因此，您应该及时运行 `exit` 以避免启动的进程被终止。
```

- 首先，使用电子邮件地址和密码登录 http://your-domain.com/admin。
- 其次，使用此用户名和密码登录 http://your-domain.com/jobs 查看是否有失败的任务。
    - 用户名和密码可以通过运行 `EDITOR="vim\" bin/rails credentials:edit` 获取。

### 重启 "Solid Queue" 处理后台任务

当与后台任务相关的代码发生更改时，您需要重新启动 "Solid Queue" 才能使更改生效。

```shell
ps -ef|grep solid
kill -9 the_solid-queue-supervisor_pid
ps -ef|grep solid # 验证没有列出相关进程。
nohup bin/jobs & # 启动它。“/nohup.out”是日志文件。
ps -ef|grep solid # 确认它已启动。
```

## 创建并安装您的 "GitHub App" 以将本地 "markdown-blog" 仓库的文件更改同步到博客网站

在这里，博客网站是您的真实 Web 服务器。

如果您不熟悉如何使用 *Markdown* 和 *Git* 发布博客，请阅读 [markdown-blog](https://github.com/developer-portfolios/markdown-blog)。

请按照 [GitHub_App.md](/docs/GitHub_App.md) 中的说明完成此步骤。

## 自动生成图片缩略图

我们使用 [ImageMagick](https://imagemagick.org/) 来生成图片缩略图。

```shell
cd /usr/local/sbin
curl -O https://imagemagick.org/archive/binaries/magick
chmod 755 magick
exit

magick -version # 测试是否已成功安装。
```

## 支持网站的 "https"

### 方式 1：使用第三方服务，如 CloudFlare 等，大的域名服务商一般会免费提供本服务（推荐）

这是最方便的方式。

如果您使用 CloudFlare SSL/TLS 加密的默认模式 `Flexible`，您可以看到 "https" 已经被支持。

您可以访问 https://your-domain.com 来检查。

### 方式 2：自行实现对 "https" 的支持

请阅读 [enable_https](/docs/deploy/enable_https.md)。

## 重定向

在 CloudFlare 仪表板中，点击 `Rules`。

### 将 http:// 重定向到 https://

- `规则模板` > 选择模板 `Redirect from HTTP to HTTPS` > `创建规则`。
- 无需更改任何内容，只需点击 `Deploy`。

### 将 www.your-domain.com 重定向到 your-domain.com

- `规则模板` > 选择模板 `Redirect from WWW to Root` > `创建规则`。
- 无需更改任何内容，只需点击 `Deploy`。

## 设置您的网站

阅读 [setup_website.md](/docs/setup_website.md)。

## 如何将网站升级到最新版本。

```shell
pkill -F /var/run/blog.pid # 停止 Rails Web 服务器
# 下面两行是停止 Rails Web 服务器的另一种方式
#ps -ef | grep puma # 您将获得一个与 `cat /var/run/blog.pid` 相同的 pid。
#kill -9 主进程pid # 一些工作进程是由主进程启动的，您可以终止主进程 pid。

cd /srv/developer-portfolio-engine
git stash
git pull origin main
git stash apply
bundle install
rails db:migrate # 如果没有添加新的迁移文件，您可以跳过此步骤。运行它没有副作用。
rails db:seed # 如果 `db/seeds.rb` 没有更改，您可以跳过此步骤。运行它没有副作用。
rails assets:precompile # 每当任何资源发生更改时都需要执行此操作。
```

- 然后按照 `## 启动或重启 Rails Web 服务器` 部分重新启动 Rails Web 服务器。
- 按照 `### 重启 "Solid Queue" 处理后台任务` 部分重新启动 "Solid Queue"。

## 数据库备份

```shell
# 在您的本地计算机上运行它
scp root@the_server_ip:/srv/developer-portfolio-engine/storage/production.sqlite3 ./
```
