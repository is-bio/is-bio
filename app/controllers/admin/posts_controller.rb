class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: %i[ edit update ]

  def new
    @post = Post.new
    @categories = Category.includes(:parent).where.not(parent_id: nil).map do |category|
      [
        "#{category.parent.name} - #{category.name}",
        category.id
      ]
    end
    @categories = [ Category::DRAFTS_ID, Category::PUBLISHED_ID ].map do |category_id|
      Category.find(category_id)
    end.map do |category|
      [ category.name, category.id ]
    end + @categories
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to admin_root_path, notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
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
