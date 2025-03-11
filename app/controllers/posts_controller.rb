class PostsController < ApplicationController
  allow_unauthenticated_access

  before_action :set_post, only: %i[ edit update ]

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to root_path, notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

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

  def edit
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
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

  # DELETE /posts/1
  # def destroy
  #   @post.destroy!
  #
  #   respond_to do |format|
  #     format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :permalink, :title, :content ])
    end
end
