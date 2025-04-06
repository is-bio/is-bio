class SyncImageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    file = args[0]
    filename = file["filename"]
    status = file["status"]

    if status == "renamed"
      previous_filename = file["previous_filename"]
      if (image_file?(previous_filename) && !image_file?(filename)) ||
        Directory.images?(previous_filename) && !Directory.images?(filename)
        remove_image_and_thumbnail(previous_filename)
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
  end

private

  def ensure_directory_exists(filepath)
    dir_path = File.dirname(filepath)
    FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
  end

  def remove_image_and_thumbnail(filename)
    File.delete(target_filename(filename)) if File.exist?(target_filename(filename))
    thumb_path = thumbnail_filename(target_filename(filename))
    File.delete(thumb_path) if File.exist?(thumb_path)
  end

  def target_filename(filename)
    "#{Rails.root}/public/#{filename}"
  end

  def thumbnail_filename(filename)
    return filename if filename.blank?

    filename.reverse.sub(".", "_thumb.".reverse).reverse
  end

  def image_file?(filename)
    accepted_extensions = %w[jpg jpeg gif png]
    filename = filename.downcase

    accepted_extensions.map { |extension| ".#{extension}" }.any? do |extension|
      filename.end_with?(extension)
    end
  end
end
