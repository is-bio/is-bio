class PostsController < ApplicationController
  allow_unauthenticated_access

  before_action :set_post, only: %i[ show edit update ]

  def index
    @posts = Post.all
  end

  def show
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
        content: "There is currently no content to display. \nPlease edit the `/path/to/markdown-blog-posts/published/about_me.md`, then `$ git commit` and `$ git push`.",
        created_at: Time.now
      )
    end
  end

  # def new
  #   @post = Post.new
  # end
  #

  # POST /posts
  # def create
  #   @post = Post.new(post_params)
  #
  #   respond_to do |format|
  #     if @post.save
  #       format.html { redirect_to @post, notice: "Post was successfully created." }
  #       format.json { render :show, status: :created, location: @post }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @post.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

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
