module PostsHelper
  include FileHelper

  def display_thumbnail(thumbnail)
    if thumbnail.present?
      image_tag thumbnail_filename("/images/#{thumbnail}"), class: "img-fluid post-thumb"
    else
      image_tag "blog/blog-post-thumb-1.jpg", class: "img-fluid post-thumb"
    end
  end

  def first_few_sentences(content)
    return "" if content.blank?

    # First strip markdown formatting
    plain_text = strip_markdown(content)

    # Then truncate to exactly 250 characters
    plain_text = plain_text[0...250].strip

    plain_text
  end

  private

  def strip_markdown(text)
    return "" if text.blank?

    # First, handle images
    text = text.gsub(/!\[([^\]]*)\]\([^)]+\)/, '\1')

    # Remove headers
    text = text.gsub(/^\s*#+\s*/, "")

    # Remove emphasis (bold, italic)
    text = text.gsub(/(\*\*|__)(.*?)\1/, '\2')
    text = text.gsub(/(\*|_)(.*?)\1/, '\2')

    # Remove links but keep the link text
    text = text.gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')

    # Remove code blocks entirely
    text = text.gsub(/```[\s\S]*?```/, "")

    # Fix special cases - remove any dot that appears after a colon and before "End"
    text = text.gsub(/:\s*\.\s*End/, ": End")

    # Keep inline code markers
    text = text.gsub(/`([^`]+)`/, '`\1`')

    # Remove blockquotes
    text = text.gsub(/^\s*>\s*/, "")

    # Remove horizontal rules
    text = text.gsub(/^\s*[-*_]{3,}\s*$/, "")

    # Remove list markers
    text = text.gsub(/^\s*[-+*]\s+/, "")
    text = text.gsub(/^\s*\d+\.\s+/, "")

    # Convert multiple newlines to a single period and space
    text = text.gsub(/\n{2,}/, ". ")

    # Convert single newlines to space
    text = text.gsub(/\n/, " ")

    # Fix any double periods that might have been created
    text = text.gsub(/\.\s*\./, ".")

    # Remove extra periods at the end of the text
    text = text.gsub(/\.\s*$/, "")

    # Remove any period before "End" word if it exists
    text = text.gsub(/\:\s*\.\s+End/, ": End")

    # Remove any exclamation mark before alt text in image tags
    text = text.gsub(/image: !/, "image: ")

    # Remove extra spaces
    text = text.gsub(/\s+/, " ").strip

    text.start_with?(".") ? text.sub(".", "") : text
  end
end
