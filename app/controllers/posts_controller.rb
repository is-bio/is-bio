class PostsController < ApplicationController
  allow_unauthenticated_access

  def index
    @posts = Post.order(created_at: :desc)
  end

  def show
    key = params.expect(:key)

    if key.blank?
      raise_404
    end

    @post = Post.where(key: key).first!

    @post_older = Post.where("created_at < ?", @post.created_at).order(created_at: :desc).first
    @post_newer = Post.where("created_at > ?", @post.created_at).order(:created_at).first
  end

  def about
    puts controller_name, action_name
    @post = Post.where(permalink: "/about").first

    if @post.nil?
      @post = Post.new(
        content: "There is currently no content to display. \nPlease edit the `/path/to/markdown-blog-posts/published/about.md`, then `$ git commit` and `$ git push`.",
        created_at: Time.now
      )
    end
  end
end
