class Admin::CategoriesController < Admin::BaseController
  def index
    @categories = Category.includes(:parent).order("id")
  end
end
