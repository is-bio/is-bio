class Admin::CategoriesController < Admin::BaseController
  def index
    @categories = Category.includes(:posts).all
  end
end
