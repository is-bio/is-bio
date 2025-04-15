class CategoriesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  include TranslatedPosts

  def index
  end

  def drafts_index
    render :index
  end

  def show
    @category = Category.find_by_name(params.expect(:name))

    if @category.nil?
      raise_404
    end

    translated_posts

    category_ids = @category.descendant_ids << @category.id
    @posts = @posts.includes(:category).where(category_id: category_ids).order(published_at: :desc)
  end

  def drafts_show
    @category = Category.find_by_name_from_drafts(params.expect(:name))

    if @category.nil?
      raise_404
    end

    translated_posts

    category_ids = @category.descendant_ids << @category.id
    @posts = @posts.includes(:category).where(category_id: category_ids).order(published_at: :desc)

    render :show
  end
end
