class Admin::CategoriesController < Admin::BaseController
  def index
    @categories = Category.all
  end
end
