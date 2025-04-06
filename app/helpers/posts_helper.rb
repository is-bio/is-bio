module PostsHelper
  def display_thumbnail(thumbnail)
    if thumbnail.present?
      image_tag "/images/#{thumbnail}", class: "img-fluid post-thumb"
    else
      image_tag "blog/blog-post-thumb-1.jpg", class: "img-fluid post-thumb"
    end
  end
end
