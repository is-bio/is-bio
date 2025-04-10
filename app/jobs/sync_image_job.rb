class SyncImageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    file = args[0]
    filename = file["filename"]
    status = file["status"]

    if status == "renamed"
      remove_image_and_thumbnail(file["previous_filename"])

      unless Directory.images?(filename)
        return
      end
    end

    unless image_file?(filename)
      return
    end

    if status == "removed"
      remove_image_and_thumbnail(filename)
      return
    end

    response = Faraday.new.get("https://raw.githubusercontent.com/#{Setting.where(key: "github_username").take.value}/markdown-blog/main/#{filename}")

    ensure_directory_exists(target_filename(filename))

    File.open(target_filename(filename), "wb") do |file_|
      file_.write(response.body)
    end

    generate_thumbnail(filename)
  end

private

  include FileHelper

  def remove_image_and_thumbnail(filename)
    remove_target_file(filename)

    thumb_path = thumbnail_filename(target_filename(filename))

    if File.exist?(thumb_path)
      File.delete(thumb_path)
    end
  end

  def generate_thumbnail(filename)
    source_path = target_filename(filename)
    thumb_path = thumbnail_filename(source_path)

    ImageProcessor.generate_thumbnail(source_path, thumb_path)
  end

  def image_file?(filename)
    return false if filename.blank?

    accepted_extensions = %w[jpg jpeg gif png]
    ext = File.extname(filename).downcase.delete(".")

    accepted_extensions.include?(ext)
  end
end
