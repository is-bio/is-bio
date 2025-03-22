class RetrieveGithubFileJob < ApplicationJob
  queue_as :default

  def perform(*args)
    file = args[0]
    filename = file["filename"]

    unless valid_extension?(filename)
      return
    end

    contents = GithubClient.new.file_contents(file["contents_url"]).body
    Post.create_from_file_contents!(filename, contents)
  end

private

  def valid_extension?(filename)
    accepted_extensions = %w[markdown md jpg jpeg gif png]
    filename.downcase!

    accepted_extensions.map { |extension| ".#{extension}" }.any? do |extension|
      filename.end_with?(extension)
    end
  end
end
