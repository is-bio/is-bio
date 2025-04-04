require "rails_helper"

RSpec.describe RetrieveGithubFileJob, type: :job do
  describe "#perform" do
    let(:github_client) { instance_double(GithubClient) }
    let(:file_response) { instance_double(Faraday::Response, body: "content") }

    before do
      allow(GithubClient).to receive(:new).and_return(github_client)
      allow(github_client).to receive(:file_contents).and_return(file_response)
    end

    context "with markdown files" do
      context "when status is 'added'" do
        let(:file) {
          {
            "filename" => "published/test-post.md",
            "status" => "added",
            "contents_url" => "https://api.github.com/repos/user/repo/contents/test-post.md"
          }
        }

        it "retrieves file contents and creates a post" do
          expect(github_client).to receive(:file_contents).with(file["contents_url"]).and_return(file_response)
          expect(Post).to receive(:sync_from_file_contents!).with("added", "published/test-post.md", "content")

          RetrieveGithubFileJob.perform_now(file)
        end
      end

      context "when status is 'modified'" do
        let(:file) {
          {
            "filename" => "published/test-post.md",
            "status" => "modified",
            "contents_url" => "https://api.github.com/repos/user/repo/contents/test-post.md"
          }
        }

        it "retrieves file contents and updates the post" do
          expect(github_client).to receive(:file_contents).with(file["contents_url"]).and_return(file_response)
          expect(Post).to receive(:sync_from_file_contents!).with("modified", "published/test-post.md", "content")

          RetrieveGithubFileJob.perform_now(file)
        end
      end

      context "when status is 'removed'" do
        let(:file) { { "filename" => "published/test-post.md", "status" => "removed" } }
        let(:post) { instance_double(Post) }

        it "deletes the post" do
          allow(Post).to receive(:find_by).with(filename: "published/test-post.md").and_return(post)
          expect(post).to receive(:destroy!)

          RetrieveGithubFileJob.perform_now(file)
        end

        it "handles case when post is not found" do
          allow(Post).to receive(:find_by).with(filename: "published/test-post.md").and_return(nil)

          expect {
            RetrieveGithubFileJob.perform_now(file)
          }.not_to raise_error
        end
      end

      context "when status is 'renamed'" do
        context "when renamed file is no longer a markdown file" do
          let(:file) { { "filename" => "published/test-post.txt", "status" => "renamed", "previous_filename" => "published/test-post.md" } }
          let(:post) { instance_double(Post) }

          it "deletes the post" do
            allow(Post).to receive(:find_by).with(filename: "published/test-post.md").and_return(post)
            expect(post).to receive(:destroy!)

            RetrieveGithubFileJob.perform_now(file)
          end
        end

        context "when file is moved out of syncable directory" do
          let(:file) { { "filename" => "other/test-post.md", "status" => "renamed", "previous_filename" => "published/test-post.md" } }
          let(:post) { instance_double(Post) }

          before do
            allow(Category).to receive(:should_sync?).with("published/test-post.md").and_return(true)
            allow(Category).to receive(:should_sync?).with("other/test-post.md").and_return(false)
          end

          it "deletes the post" do
            allow(Post).to receive(:find_by).with(filename: "published/test-post.md").and_return(post)
            expect(post).to receive(:destroy!)

            RetrieveGithubFileJob.perform_now(file)
          end
        end

        context "when both filenames are valid markdown files in syncable directories" do
          let(:file) { {
            "filename" => "published/new-name.md",
            "status" => "renamed",
            "previous_filename" => "drafts/old-name.md",
            "contents_url" => "https://api.github.com/repos/user/repo/contents/new-name.md"
          } }

          before do
            allow(Category).to receive(:should_sync?).with("drafts/old-name.md").and_return(true)
            allow(Category).to receive(:should_sync?).with("published/new-name.md").and_return(true)
          end

          it "syncs the post with the new filename" do
            expect(github_client).to receive(:file_contents).with(file["contents_url"]).and_return(file_response)
            expect(Post).to receive(:sync_from_file_contents!).with("renamed", "published/new-name.md", "content")

            RetrieveGithubFileJob.perform_now(file)
          end
        end
      end
    end

    context "with non-markdown files" do
      let(:file) { { "filename" => "published/test-post.txt", "status" => "added" } }

      it "skips processing" do
        expect(github_client).not_to receive(:file_contents)
        expect(Post).not_to receive(:sync_from_file_contents!)

        RetrieveGithubFileJob.perform_now(file)
      end
    end

    context "with different markdown extensions" do
      let(:file_md) { { "filename" => "published/test-post.md", "status" => "added", "contents_url" => "url1" } }
      let(:file_markdown) { { "filename" => "published/test-post.markdown", "status" => "added", "contents_url" => "url2" } }

      it "processes .md files" do
        expect(github_client).to receive(:file_contents).with("url1").and_return(file_response)
        expect(Post).to receive(:sync_from_file_contents!)

        RetrieveGithubFileJob.perform_now(file_md)
      end

      it "processes .markdown files" do
        expect(github_client).to receive(:file_contents).with("url2").and_return(file_response)
        expect(Post).to receive(:sync_from_file_contents!)

        RetrieveGithubFileJob.perform_now(file_markdown)
      end
    end

    context "with mixed case extensions" do
      let(:file) { { "filename" => "published/test-post.MD", "status" => "added", "contents_url" => "url" } }

      it "processes files case-insensitively" do
        expect(github_client).to receive(:file_contents).with("url").and_return(file_response)
        expect(Post).to receive(:sync_from_file_contents!)

        RetrieveGithubFileJob.perform_now(file)
      end
    end
  end

  describe "#markdown_file?" do
    let(:job) { RetrieveGithubFileJob.new }

    it "identifies .md files as markdown" do
      expect(job.send(:markdown_file?, "test.md")).to be true
    end

    it "identifies .markdown files as markdown" do
      expect(job.send(:markdown_file?, "test.markdown")).to be true
    end

    it "handles uppercase extensions" do
      expect(job.send(:markdown_file?, "test.MD")).to be true
    end

    it "rejects non-markdown files" do
      expect(job.send(:markdown_file?, "test.txt")).to be false
      expect(job.send(:markdown_file?, "test.html")).to be false
      expect(job.send(:markdown_file?, "test")).to be false
    end
  end

  describe "job enqueuing" do
    let(:file) { { "filename" => "published/post.md", "status" => "added" } }

    it "enqueues with the default queue" do
      expect {
        RetrieveGithubFileJob.perform_later(file)
      }.to have_enqueued_job(RetrieveGithubFileJob)
             .with(file)
             .on_queue("default")
    end
  end
end
