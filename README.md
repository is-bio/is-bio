# Enjoy blogging with Markdown and Git. An open source personal blog based on Ruby on Rails 8.

## Free theme 'DevBlog' installation

### Download 'DevBlog' Theme

- Option 1: Use Git to download.

    If your network is not good, you can try `option 2`.

    ```shell
    cd _themes
    git clone https://github.com/xriley/DevBlog-Theme.git
    ```

- Option 2: Download zip file and unzip it to `./_themes` folder.
    1. The zip file is at:
        - GitHub: [DevBlog-Theme zip](https://github.com/xriley/DevBlog-Theme/archive/refs/heads/master.zip)
        - Or official website: [DevBlog Theme](https://themes.3rdwavemedia.com/bootstrap-templates/personal/devblog-free-bootstrap-5-blog-template-for-developers/).
    2. Copy `DevBlog-Theme-master.zip` into `./_themes`.
    3. Run `cd ./_themes && unzip DevBlog-Theme-master.zip`.
    4. Run `mv DevBlog-Theme-master DevBlog-Theme` to rename it.

### Install 'DevBlog' Theme

Run:

```shell
cd ./_themes # if not in this folder
sh install-theme-devblog.sh
```

## Run tests

Run `bundle exec rspec spec`.
