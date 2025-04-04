require "rails_helper"

RSpec.describe Api::V1::GithubEventsController, type: :controller do
  let(:setting) { instance_double(Setting, value: "correct-username") }
  let(:github_client) { instance_double(GithubClient) }
  let(:compare_response) {
    instance_double(
      Faraday::Response,
      body: {
        "files" => [
          { "filename" => "published/test-post.md", "status" => "added" },
          { "filename" => "drafts/draft-post.md", "status" => "modified" },
          { "filename" => "other/ignored-file.md", "status" => "modified" },
          { "filename" => "published/renamed-post.md", "status" => "renamed", "previous_filename" => "published/old-name.md" }
        ]
      }
    )
  }
  let(:params) {
    ActionController::Parameters.new(
      {
        before: "abc123",
        after: "def456",
        ref: "refs/heads/main",
        repository: {
          name: "markdown-blog",
          owner: { login: "correct-username" }
        }
      }
    ).permit!
  }

  before do
    allow(controller).to receive(:authenticate_sender!)
    allow(Setting).to receive(:where).with(key: "github_username").and_return(double(take: setting))
    allow(controller).to receive(:params).and_return(params)
    allow(GithubClient).to receive(:new).and_return(github_client)
    allow(github_client).to receive(:compare).and_return(compare_response)
  end

  describe "#handle" do
    context "when files are modified in published or drafts directories" do
      it "enqueues jobs for relevant files" do
        expect(RetrieveGithubFileJob).to receive(:perform_later).with(
          { "filename" => "published/test-post.md", "status" => "added" }
        )
        expect(RetrieveGithubFileJob).to receive(:perform_later).with(
          { "filename" => "drafts/draft-post.md", "status" => "modified" }
        )
        expect(RetrieveGithubFileJob).to receive(:perform_later).with({
          "filename" => "published/renamed-post.md",
          "status" => "renamed",
          "previous_filename" => "published/old-name.md"
        })

        post :handle
      end

      it "does not enqueue jobs for files in other directories" do
        expect(RetrieveGithubFileJob).not_to receive(:perform_later).with(
          { "filename" => "other/ignored-file.md", "status" => "modified" }
        )

        post :handle
      end
    end

    context "when compare request fails" do
      before do
        allow(github_client).to receive(:compare).and_raise(Faraday::Error.new("Connection failed"))
      end

      it "raises an error" do
        expect {
          post :handle
        }.to raise_error(Faraday::Error)
      end
    end

    context "when files array is empty" do
      let(:compare_response) {
        instance_double(Faraday::Response, body: { "files" => [] })
      }

      it "does not enqueue any jobs" do
        expect(RetrieveGithubFileJob).not_to receive(:perform_later)

        post :handle
      end
    end
  end

  describe "before actions" do
    it "before actions should be called" do
      expect(controller).to receive(:authenticate_sender!).ordered
      expect(controller).to receive(:verify_branch!).ordered
      expect(controller).to receive(:verify_repository_name!).ordered
      expect(controller).to receive(:verify_github_username!).ordered
      expect(controller).to receive(:handle).ordered

      post :handle
    end
  end

  describe "#authenticate_sender!" do
    it "raises a routing error" do
      allow(controller).to receive(:authenticate_sender!).and_raise(ActionController::RoutingError.new("Not Found"))
      post :handle
      expect(response.status).to eq(404)
    end
  end

  describe "#verify_branch!" do
    context "when branch is main" do
      it "passes verification" do
        expect {
          controller.send(:verify_branch!)
        }.not_to raise_error
      end
    end

    context "when branch is not main" do
      it "raises a routing error" do
        params["ref"] = "refs/heads/not-main"
        allow(controller).to receive(:params).and_return(params)

        expect {
          controller.send(:verify_branch!)
        }.to raise_error(ActionController::RoutingError, "The system only processes events from the 'main' branch!")
      end
    end
  end

  describe "#verify_repository_name!" do
    context "when repository name is correct" do
      it "passes verification" do
        expect {
          controller.send(:verify_repository_name!)
        }.not_to raise_error
      end
    end

    context "when repository name is incorrect" do
      it "raises a routing error" do
        params["repository"] = { name: "not-markdown-blog" }
        allow(controller).to receive(:params).and_return(params)

        expect {
          controller.send(:verify_repository_name!)
        }.to raise_error(ActionController::RoutingError, "The system only processes events from repository named 'markdown-blog'!")
      end
    end
  end

  describe "#verify_github_username!" do
    context "when github_username matches repository owner" do
      it "passes verification" do
        expect {
          controller.send(:verify_github_username!)
        }.not_to raise_error
      end
    end

    context "when github_username setting doesn't exist" do
      it "raises a routing error" do
        allow(Setting).to receive(:where).with(key: "github_username").and_return(double(take: nil))

        expect {
          controller.send(:verify_github_username!)
        }.to raise_error(ActionController::RoutingError, "There is no record with key='github_username' in the 'settings' table! Please insert it first.")
      end
    end

    context "when github_username exists but doesn't match repository owner" do
      it "raises a routing error" do
        params["repository"]["owner"] = { login: "wrong-username" }
        allow(controller).to receive(:params).and_return(params)

        expect {
          controller.send(:verify_github_username!)
        }.to raise_error(ActionController::RoutingError, "The repository owner's username does not match the username set in table 'settings'!")
      end
    end
  end
end
