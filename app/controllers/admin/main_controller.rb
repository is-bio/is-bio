class Admin::MainController < Admin::BaseController
  def root
    @category_drafts = Category.find(Category::ID_DRAFTS)
    @category_published = Category.find(Category::ID_PUBLISHED)
  end
end
