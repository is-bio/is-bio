class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: %i[ edit update destroy ]
  before_action :set_category_options, only: %i[ new edit ]

  def new
    @post = Post.new(published_at: Time.current)
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post.path
    else
      set_category_options
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless I18n.locale == I18n.default_locale
      translation = @post.current_translation

      if translation.nil?
        render :edit
      else
        redirect_to edit_admin_post_translation_path(@post, @post.current_translation)
      end
    end
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params)
      redirect_to @post.path, notice: "Post was successfully updated."
    else
      set_category_options
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy!

    redirect_to root_path, status: :see_other, notice: "Post was successfully destroyed."
  end

private

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
    params.expect(post: [ :id, :id2, :permalink, :title, :content, :category_id, :published_at, :thumbnail ])
  end
end
