class RetrieveGithubFileJob < ApplicationJob
  queue_as :default

  def perform(*args)
    file = args[0]
    filename = file["filename"]
    status = file["status"]

    if status == "renamed"
      previous_filename = file["previous_filename"]
      if (markdown_file?(previous_filename) && !markdown_file?(filename)) ||
        Category.should_sync?(previous_filename) && !Category.should_sync?(filename)
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
    Post.sync_from_file_contents!(file["status"], filename, contents)
  end

private

  def markdown_file?(filename)
    accepted_extensions = %w[markdown md]
    filename = filename.downcase

    accepted_extensions.map { |extension| ".#{extension}" }.any? do |extension|
      filename.end_with?(extension)
    end
  end
end
