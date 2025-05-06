[English README](README.md)

# 开发者作品集引擎 | 免费模板

## 使用 "Markdown" 和 "Git" 享受博客写作

演示网站：[张健的博客](https://zhangjian.blog)。

## 如何在本地使用 Markdown 文件撰写文章，并通过 `git push` 发布？

目前，[Jekyll](https://jekyllrb.com/) 或 [Hugo](https://gohugo.io/) 已经可以满足上述要求，但并不完美。

**developer-portfolio-engine** 也可以满足上述要求，但有几点不同。

## *developer-portfolio-engine* 在哪些方面比 Jekyll 或 Hugo **更好**？

1. Jekyll 或 Hugo 生成的博客文章是*静态*的，而 *developer-portfolio-engine* 是一个**动态**博客引擎。
    - *静态*博客的功能非常有限。
    - 在*动态*博客 *developer-portfolio-engine* 中，目前已集成电子邮件订阅功能，未来还将支持简历、作品集、评论、点赞、阅读次数、在线支付等功能。
    - 此外，您还可以为您的博客**添加一些自定义功能**。
    - 您可能会说，如果我不会用 Ruby 编程怎么办？
        - 两年前，这会是个问题，但现在，我们有了 AI，您可以**让 AI 帮助您实现一些小功能**！
        - 如果出现错误，告诉 AI 并让 AI 纠正它。
2. 对于不熟悉 Jekyll 或 Hugo 的人来说，即使是找到一个好看的主题也很**困难**。
    - *developer-portfolio-engine* 目前支持一个**漂亮的免费主题（内含8种色调）**，未来还会添加更多主题。
3. Jekyll 或 Hugo 的文档长达很多页。谁能在一页内解释清楚所有内容？
    - *developer-portfolio-engine* 可以。有关如何使用 *developer-portfolio-engine* 方法通过 *Markdown* 和 *Git* 发布帖子的信息，请阅读 [markdown-blog](https://github.com/developer-portfolios/markdown-blog)。
4. 一篇博客文章可以翻译成多种语言并在博客上显示。这个功能目前还没有任何博客引擎支持。然而，*developer-portfolio-engine* 已经支持了，让您的文章能够触达全球用户。八种语言：英语，汉语，西班牙语，德语，法语，葡萄牙语，日语，俄语已经默认支持，其它语言也可以轻松支持。
5. 对于建立个人品牌来说，仅有一个博客是不够的。最好有简历和作品集。事实上，博客并不是最重要的功能，**简历和作品集才是**。在下一个版本中，我们将推出简历功能。

## 使用 *developer-portfolio-engine* 的成本是多少？

许多程序员已经在使用服务器，通常，该服务器并未得到充分利用。

您可以在此服务器上安装 *developer-portfolio-engine*，而无需担心端口 `80/443` 被另一个网站占用。在安装文档中，我已经指出了如何完美解决这个实际不存在的问题。

因此，您的成本增加可能仅仅是 $2/月。

## 为什么开发者不再经常写博客了？

- 在使用 [GitHub Pages](https://pages.github.com/)（基于 Jekyll）后，他们**很少**写博客了。为什么？
- 在我看来，普通的博客系统**无法再为博主创造太多价值**！那些博客并非旨在为博主带来价值。
- 以我自己为例，我的 GitHub Pages 的 [张健的旧博客](https://gazeldx.github.io/) 一点也不吸引人，所以我无法兴奋地写作。

## developer-portfolio-engine：一个专注于为开发者带来价值的博客引擎

- 您可以看到 [张健的新博客](https://zhangjian.blog)（基于 *developer-portfolio-engine*）设计精良。
- 我开始期望客户**直接在我的博客上为我的服务付费**！
- 通过博客，我向潜在客户传达了一个信息：我是 Web 开发、算法和戒断游戏成瘾方面的专家！

# 在服务器上部署 developer-portfolio-engine

如果您想在服务器上部署 *developer-portfolio-engine*，请阅读 [deploy_on_CentOS10.md](/docs/deploy/deploy_on_CentOS10.md)。

# 在本地计算机上安装 developer-portfolio-engine

以下内容主要针对在 *macOS* 本地进行安装。对于其他操作系统，安装过程类似。

## 安装 Ruby

*developer-portfolio-engine* 是基于 Ruby 3.3.x 版本开发的，但其他版本应该也可以工作。

- 如果您是临时用户并且不经常使用 Ruby，请使用 Homebrew 安装 Ruby。

    ```shell
    brew install ruby
    ```

- Ruby 开发者使用 Ruby 版本管理器来安装 Ruby。
    - [ruby-build](https://github.com/rbenv/ruby-build)
    - [ruby-install](https://github.com/postmodern/ruby-install)
    - [asdf](https://github.com/asdf-vm/asdf)

## 克隆 'developer-portfolio-engine' 仓库并安装 Ruby gems

```shell
git clone https://github.com/developer-portfolios/developer-portfolio-engine.git
cd /path/to/developer-portfolio-engine
bundle install
```

## 设置credentials

```shell
cd /path/to/developer-portfolio-engine
# 此文件包含所有需要设置的credentials。
cat config/credentials.yml.example # 使用下一个命令设置"所有"credentials：
# 保存后，将创建 "config/credentials.yml.enc" 和 "config/master.key"。
# 为了使修改后的credentials生效，您需要重新启动 Rails Web 服务器。
EDITOR="vim" bin/rails credentials:edit
```

`config/credentials.yml.example` 中显示的所有项目都需要设置！

如果您仍然不确定如何设置某些项目，可以先使用 `config/credentials.yml.example` 中的默认值，然后在发现相关功能不起作用时，根据相关说明正确设置值。

## 准备 SQLite 数据库

```shell
cd /path/to/developer-portfolio-engine
rails db:migrate # 数据库文件是 `./storage/development.sqlite3`。运行它没有副作用。
rails db:seed # 运行它没有副作用。
```

## 安装主题

阅读 [docs/install_theme.md](/docs/install_theme.md)。

## 启动 Rails Web 服务器

```shell
cd /path/to/developer-portfolio-engine
rails assets:precompile # 每当任何资源发生更改时都需要执行此操作。运行它没有副作用。
rails s # 启动 Rails Web 服务器。
```

访问 http://localhost:3000/。

### 创建管理员用户

```shell
cd /path/to/developer-portfolio-engine
vim db/seeds.rb
```

取消注释代码的前几行以创建管理员用户。

```shell
rails db:seed
git restore db/seeds.rb
```

使用此电子邮件地址和密码登录 http://localhost:3000/admin。

## 通过 SMTP 发送电子邮件

请按照 [docs/send_email_via_smtp_guide.md](/docs/send_email_via_smtp_guide.md) 中的说明完成此步骤。

## 启动 "Solid Queue" 处理后台任务

博客文章、图片、文件同步、发送电子邮件、生成缩略图等都需要启动后台任务！

```shell
cd /path/to/developer-portfolio-engine
rm public/assets/.manifest.json
rails assets:precompile # 您需要重新启动 Rails Web 服务器才能使更改生效。
bin/jobs # 启动它
```

- 首先，使用电子邮件地址和密码登录 http://localhost:3000/admin。
- 其次，使用此用户名和密码登录 http://localhost:3000/jobs 查看是否有失败的任务。
    - 用户名和密码可以通过运行 `EDITOR="vim" bin/rails credentials:edit` 获取。

## 创建并安装您的 "GitHub App" 以将本地 "markdown-blog" 仓库的文件更改同步到博客网站

在这里，博客网站是您的本地 Rails Web 服务器。如果您 [deploy_on_CentOS10.md](/docs/deploy/deploy_on_CentOS10.md)，博客网站是您的真实 Web 服务器。

如果您不熟悉如何使用 *Markdown* 和 *Git* 发布博客，请阅读 [markdown-blog](https://github.com/developer-portfolios/markdown-blog)。

请按照 [GitHub_App.md](/docs/GitHub_App.md) 中的说明完成此步骤。

## 自动生成图片缩略图

<details>
  <summary>点击查看</summary>
  您需要安装 [ImageMagick](https://imagemagick.org/)。<br>
如果您在本地调试时不关心缩略图，可以跳过此步骤，仅在服务器上安装 *ImageMagick*。

```shell
# 警告：此命令可能需要很长时间并下载大量软件包！
brew install imagemagick
```
</details>

## 运行测试

运行 `bundle exec rspec spec`。

## 故障排除

```shell
cd /path/to/developer-portfolio-engine
tail -n 200 log/development.log # 这是 Rails Web 服务器的日志

# 如果您正在测试与后台作业相关的功能，可以使用它来检查作业进程是否正在运行。
# 如果您没有看到列出的任何进程，可以通过阅读上面的说明来启动它。
ps -ef|grep solid
```

## 设置您的网站

阅读 [setup_website.md](/docs/setup_website.md)。 
