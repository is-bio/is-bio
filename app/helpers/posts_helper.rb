module PostsHelper
  include FileHelper

  def display_thumbnail(thumbnail)
    if thumbnail.present?
      image_tag thumbnail_filename("/images/#{thumbnail}"), class: "img-fluid post-thumb"
    else
      image_tag "blog/blog-post-thumb-1.jpg", class: "img-fluid post-thumb"
    end
  end
end
