class PostsController < ApplicationController
  allow_unauthenticated_access

  def index
    @posts = Post.includes(:category).published.order(published_at: :desc)
  end

  def show
    id = params.expect(:id)

    if id.blank?
      raise_404
    end

    if authenticated?
      @post = Post.find(id)
    else
      @post = Post.published.find(id)
    end

    if @post.permalink != "/#{CGI.escape(params.expect(:permalink))}"
      redirect_to @post.path, status: :moved_permanently
    end

    @post_older = Post.published.where("published_at < ?", @post.published_at).order(published_at: :desc).first
    @post_newer = Post.published.where("published_at > ?", @post.published_at).order(:published_at).first
  end

  def about
    @post = Post.where(permalink: "/about").first

    if @post.nil?
      @post = Post.new(
        content: "There is currently no content to display. \nPlease edit the `/path/to/markdown-blog/published/about.md`, then `$ git commit` and `$ git push`.",
        published_at: Time.current
      )
    end
  end

  # TODO: In creation or modification, make sure if permalink is empty, or /, we generate from title.
end
