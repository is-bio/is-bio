class SyncMarkdownFileJob < ApplicationJob
  queue_as :default

  def perform(*args)
    file = args[0]
    filename = file["filename"]
    status = file["status"]

    if status == "renamed"
      previous_filename = file["previous_filename"]
      if (markdown_file?(previous_filename) && !markdown_file?(filename)) ||
        Directory.published_or_drafts?(previous_filename) && !Directory.published_or_drafts?(filename)
        post = Post.find_by(filename: previous_filename)
        if post.present?
          post.destroy!
        end
        return
      end
    end

    unless markdown_file?(filename)
      return
    end

    if status == "removed"
      post = Post.find_by(filename: filename)
      if post.present?
        post.destroy!
      end
      return
    end

    contents = GithubClient.new.file_contents(file["contents_url"]).body

    if status == "renamed" && file["changes"] != 0
      status = "renamed_and_modified"
    end

    Post.sync_from_file_contents!(status, filename, contents)
  end

private

  def markdown_file?(filename)
    return false if filename.blank?

    accepted_extensions = %w[markdown md]
    ext = File.extname(filename).downcase.delete(".")

    accepted_extensions.include?(ext)
  end
end
