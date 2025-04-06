class SyncFileJob < ApplicationJob
  queue_as :default

  def perform(*args)
    file = args[0]
    filename = file["filename"]
    status = file["status"]

    if status == "renamed"
      remove_target_file(file["previous_filename"])

      unless Directory.files?(filename)
        return
      end
    end

    if status == "removed"
      remove_target_file(filename)
      return
    end

    response = Faraday.new.get("https://raw.githubusercontent.com/#{Setting.where(key: "github_username").take.value}/markdown-blog/main/#{filename}")

    ensure_directory_exists(target_filename(filename))

    File.open(target_filename(filename), "wb") do |file_|
      file_.write(response.body)
    end
  end

private

  include FileHelper
end

