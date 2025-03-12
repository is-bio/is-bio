class CategoriesController < ApplicationController
  allow_unauthenticated_access

  def show
    # puts params.inspect
    category_id = params.expect(:id)
    params.expect(:name)

    Category.find(category_id).children
  end
end
