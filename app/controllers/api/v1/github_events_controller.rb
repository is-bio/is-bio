# noinspection RubyNilAnalysis
class Api::V1::GithubEventsController < Api::V1::BaseController
  before_action :authenticate_sender!
  before_action :verify_branch!
  before_action :verify_repository_name!
  before_action :verify_github_username!
  # TODO: 'repository.private' rejected?

  def handle
    before = params.expect(:before)
    after = params.expect(:after)
    body = GithubClient.new.compare(before, after).body

    body["files"].each do |file|
      if Category.should_sync?(file["filename"])
      end
    end
  end

private

  def verify_branch!
    if params.expect(:ref) != "refs/heads/main"
      raise_404("The system only processes events from the 'main' branch!")
    end
  end

  def verify_repository_name!
    if params.expect(repository: {})[:name] != "markdown-blog"
      raise_404("The system only processes events from repository named 'markdown-blog'!")
    end
  end

  def verify_github_username!
    github_username_setting = Setting.where(key: "github_username").take

    if github_username_setting.nil?
      raise_404("There is no record with key='github_username' in the 'settings' table! Please insert it first.")
    end

    if params.expect(repository: {})[:owner][:login] != github_username_setting.value
      raise_404("The repository owner's username does not match the username set in table 'settings'!")
    end
  end
end
