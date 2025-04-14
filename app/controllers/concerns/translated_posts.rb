module TranslatedPosts
  extend ActiveSupport::Concern

  included do
    helper_method :translated_posts
  end

  def translated_posts
    if default_locale?
      @posts = Post.all
    else
      if current_locale.present?
        @posts = current_locale.posts.includes(:translations).where("translations.locale_id = ?", current_locale.id)
      else
        @posts = Post.none
      end
    end
  end
end
