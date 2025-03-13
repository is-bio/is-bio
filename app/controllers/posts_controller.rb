class PostsController < ApplicationController
  allow_unauthenticated_access

  def index
    @posts = Post.includes(:category).published.order(created_at: :desc)
  end

  def show
    key = params.expect(:key)

    if key.blank?
      raise_404
    end

    if authenticated?
      @post = Post.where(key: key).first!
    else
      @post = Post.published.where(key: key).first!
    end

    if @post.permalink != "/#{CGI.escape(params.expect(:permalink))}"
      redirect_to @post.path, status: :moved_permanently
    end

    @post_older = Post.published.where("created_at < ?", @post.created_at).order(created_at: :desc).first
    @post_newer = Post.published.where("created_at > ?", @post.created_at).order(:created_at).first
  end

  def about
    @post = Post.where(permalink: "/about").first

    if @post.nil?
      @post = Post.new(
        content: "There is currently no content to display. \nPlease edit the `/path/to/markdown-blog-posts/published/about.md`, then `$ git commit` and `$ git push`.",
        created_at: Time.now
      )
    end
  end
end
