class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: %i[ edit update ]
  before_action :set_category_options, only: %i[ new create edit update ]

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post.path
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

private

  # DELETE /posts/1
  # def destroy
  #   @post.destroy!
  #
  #   respond_to do |format|
  #     format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params.expect(:id))
  end

  def set_category_options
    @category_options = Category.all.map do |category|
      [
        "#{category.has_parent? ? "#{category.parent.name} - " : nil }#{category.name}",
        category.id
      ]
    end
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.expect(post: [ :permalink, :title, :content, :category_id ])
  end
end
