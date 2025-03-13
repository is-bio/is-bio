class CategoriesController < ApplicationController
  allow_unauthenticated_access

  def show
    category_id = params.expect(:id).to_i

    unless authenticated?
      unless Category.published_ids.include?(category_id)
        raise_404
      end
    end

    category = Category.find(category_id)

    if category.url_safe_name != CGI.escape(params.expect(:name))
      redirect_to category.path, status: :moved_permanently
    end

    category_ids = category.descendant_ids << category_id

    @posts = Post.includes(:category).where(category_id: category_ids).order(created_at: :desc)

    unless authenticated?
      @posts = @posts.published
    end
  end
end
