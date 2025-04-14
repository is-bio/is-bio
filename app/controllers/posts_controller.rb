class PostsController < ApplicationController
  allow_unauthenticated_access

  def index
    if I18n.locale == I18n.default_locale
      @posts = Post.all
    else
      locale = Locale.find_by(key: I18n.locale)
      if locale
        @posts = locale.posts.includes(:translations).where("translations.locale_id = ?", locale.id)
      else
        @posts = Post.none
      end
    end

    @posts = @posts.includes(:category).published.order(published_at: :desc)
  end

  def show
    id2 = params.expect(:id2)

    if id2.blank?
      raise_404
    end

    if authenticated?
      @post = Post.find_by!(id2: id2)
    else
      @post = Post.published.find_by!(id2: id2)
    end

    if @post.permalink != "/#{CGI.escape(params.expect(:permalink))}"
      redirect_to @post.path, status: :moved_permanently
    end

    @post_older = Post.published.where("published_at < ?", @post.published_at).order(published_at: :desc).first
    @post_newer = Post.published.where("published_at > ?", @post.published_at).order(:published_at).first

    @post.translated!
  end

  def about
    @post = Post.where(permalink: "/about").first

    if @post.nil?
      @post = Post.new(
        content: "There is currently no content to display. \nPlease edit the `/path/to/markdown-blog/published/about.md`, then commit the changes and `$ git push`.",
        published_at: Time.current
      )
    end
  end

  def hire
    @post = Post.where(permalink: "/hire").first

    if @post.nil?
      @post = Post.new(
        content: "There is currently no content to display. \nPlease edit the `/path/to/markdown-blog/published/hire.md`, then commit the changes and `$ git push`.",
        published_at: Time.current
      )
    end

    render :about
  end
end
