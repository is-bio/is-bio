require "mini_magick"

# noinspection RubyNilAnalysis
class ImageProcessor
  DEFAULT_THUMBNAIL_WIDTH = 300

  def self.generate_thumbnail(source_path, target_path, width = DEFAULT_THUMBNAIL_WIDTH)
    unless File.exist?(source_path)
      Rails.logger.error("==== Image not found: #{source_path}")
      raise "Source image file not found at #{source_path}"
    end

    # target_dir = File.dirname(target_path) # Ensure target directory exists
    # FileUtils.mkdir_p(target_dir) unless File.directory?(target_dir)

    begin
      image = MiniMagick::Image.open(source_path)

      case File.extname(source_path).downcase
      when ".jpg", ".jpeg"
        image.resize_to_fill "#{width}x#{width}^"
        image.format "jpg"
        # image.quality 80
        image.write target_path
      when ".png"
        image.resize "#{width}x#{width}^"
        image.format "png"
        # image.quality 90 # MiniMagick uses quality for compression level in PNGs too
        image.write target_path
      when ".gif"
        # image.resize "#{width}x" # For GIF, we might lose animation but maintain format
        image.format "gif"
        image.write target_path
      else
        # Default fallback to JPEG for other formats
        image.resize "#{width}x#{width}^"
        image.format "jpg"
        # image.quality 80
        image.write target_path
      end

      Rails.logger.info("==== Thumbnail #{target_path} generated successfully.")
      true
    rescue MiniMagick::Error => exception
      Rails.logger.error("==== MiniMagick error generating thumbnail: #{exception.message}")
      Rails.logger.error(Array(exception.backtrace).join("\n"))
      false
    rescue StandardError => exception
      Rails.logger.error("==== Failed to generate thumbnail: #{exception.message}")
      Rails.logger.error(Array(exception.backtrace).join("\n"))
      false
    end
  end
end
