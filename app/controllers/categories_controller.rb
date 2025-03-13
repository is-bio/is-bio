class CategoriesController < ApplicationController
  allow_unauthenticated_access

  def show
    category_id = params.expect(:id)
    category = Category.find(category_id)

    if category.url_safe_name != CGI.escape(params.expect(:name))
      redirect_to category.path, status: :moved_permanently
    end

    category_ids = category.descendant_ids << category_id
    @posts = Post.includes(:category).where(category_id: category_ids).order(created_at: :desc)
  end
end
