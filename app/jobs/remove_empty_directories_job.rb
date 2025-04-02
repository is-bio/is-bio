class RemoveEmptyDirectoriesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    category_ids = (Post.pluck(:category_id) + [ Category::ID_PUBLISHED, Category::ID_DRAFTS ]).uniq
    categories = Category.where.not(id: category_ids)

    categories.each do |category|
      unless category.has_children?
        category.destroy!
      end
    end
  end
end
