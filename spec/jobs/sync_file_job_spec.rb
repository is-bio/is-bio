require "rails_helper"

RSpec.describe SyncFileJob, type: :job do
  describe "#perform" do
    let(:github_username) { instance_double(Setting, value: "test-user") }
    let(:response) { instance_double(Faraday::Response, body: "file-content") }
    let(:faraday_connection) { instance_double(Faraday::Connection) }
    let(:file_double) { instance_double(File) }

    before do
      allow(Setting).to receive(:where).with(key: "github_username").and_return(double(take: github_username))
      allow(Faraday).to receive(:new).and_return(faraday_connection)
      allow(File).to receive(:directory?).and_return(false)
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:exist?).and_return(false)
    end

    context "with files in the files directory" do
      context "when status is 'added'" do
        let(:file) { { "filename" => "files/document.pdf", "status" => "added" } }

        it "downloads and saves the file" do
          expect(faraday_connection).to receive(:get)
                                          .with("https://raw.githubusercontent.com/test-user/markdown-blog/main/files/document.pdf")
                                          .and_return(response)

          expect(File).to receive(:open).with(Rails.root.join("public/files/document.pdf").to_s, "wb").and_yield(file_double)
          expect(file_double).to receive(:write).with("file-content")

          SyncFileJob.perform_now(file)
        end

        it "creates the directory if it doesn't exist" do
          allow(faraday_connection).to receive(:get).and_return(response)
          allow(File).to receive(:open).and_yield(file_double)
          allow(file_double).to receive(:write)

          expect(FileUtils).to receive(:mkdir_p).with(Rails.root.join("public/files").to_s)

          SyncFileJob.perform_now(file)
        end
      end

      context "when status is 'modified'" do
        let(:file) { { "filename" => "files/document.pdf", "status" => "modified" } }

        it "downloads and replaces the file" do
          expect(faraday_connection).to receive(:get)
                                          .with("https://raw.githubusercontent.com/test-user/markdown-blog/main/files/document.pdf")
                                          .and_return(response)

          expect(File).to receive(:open).with(Rails.root.join("public/files/document.pdf").to_s, "wb").and_yield(file_double)
          expect(file_double).to receive(:write).with("file-content")

          SyncFileJob.perform_now(file)
        end
      end

      context "when status is 'removed'" do
        let(:file) { { "filename" => "files/document.pdf", "status" => "removed" } }
        let(:target_file) { Rails.root.join("public/files/document.pdf").to_s }

        before do
          allow(File).to receive(:exist?).with(target_file).and_return(true)
        end

        it "removes the file and doesn't try to download the file" do
          expect(File).to receive(:delete).with(target_file)
          expect(faraday_connection).not_to receive(:get)
          SyncFileJob.perform_now(file)
        end
      end

      context "when status is 'renamed'" do
        context "when renamed from 'files/' to another directory" do
          let(:file) { { "filename" => "docs/document.pdf", "status" => "renamed", "previous_filename" => "files/old-document.pdf" } }
          let(:previous_file_path) { Rails.root.join("public/files/old-document.pdf").to_s }

          before do
            allow(File).to receive(:exist?).with(previous_file_path).and_return(true)
          end

          it "removes the previous file and doesn't download a new one" do
            expect(File).to receive(:delete).with(previous_file_path)
            expect(faraday_connection).not_to receive(:get)

            SyncFileJob.perform_now(file)
          end
        end

        context "when renamed within the files directory" do
          let(:file) { { "filename" => "files/new-document.pdf", "status" => "renamed", "previous_filename" => "files/old-document.pdf" } }
          let(:previous_file_path) { Rails.root.join("public/files/old-document.pdf").to_s }

          before do
            allow(File).to receive(:exist?).with(previous_file_path).and_return(true)
          end

          it "removes the previous file and downloads the new one" do
            expect(File).to receive(:delete).with(previous_file_path)

            expect(faraday_connection).to receive(:get)
                                            .with("https://raw.githubusercontent.com/test-user/markdown-blog/main/files/new-document.pdf")
                                            .and_return(response)

            expect(File).to receive(:open).with(Rails.root.join("public/files/new-document.pdf").to_s, "wb").and_yield(file_double)
            expect(file_double).to receive(:write).with("file-content")

            SyncFileJob.perform_now(file)
          end
        end

        context "when renamed from another directory to 'files/'" do
          let(:file) { { "filename" => "files/document.pdf", "status" => "renamed", "previous_filename" => "docs/old-document.pdf" } }

          before do
            allow(Directory).to receive(:files?).with("files/document.pdf").and_return(true)
          end

          it "downloads the file to the files directory" do
            expect(faraday_connection).to receive(:get)
                                            .with("https://raw.githubusercontent.com/test-user/markdown-blog/main/files/document.pdf")
                                            .and_return(response)

            expect(File).to receive(:open).with(Rails.root.join("public/files/document.pdf").to_s, "wb").and_yield(file_double)
            expect(file_double).to receive(:write).with("file-content")

            SyncFileJob.perform_now(file)
          end
        end
      end
    end

    context "when GitHub API fails" do
      let(:file) { { "filename" => "files/document.pdf", "status" => "added" } }

      before do
        allow(Directory).to receive(:files?).and_return(true)
      end

      it "raises an exception" do
        allow(faraday_connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new("Failed to connect"))

        expect {
          SyncFileJob.perform_now(file)
        }.to raise_error(Faraday::ConnectionFailed)
      end
    end

    context "when GitHub username setting is missing" do
      let(:file) { { "filename" => "files/document.pdf", "status" => "added" } }

      before do
        allow(Setting).to receive(:where).with(key: "github_username").and_return(double(take: nil))
      end

      it "raises a NoMethodError" do
        expect {
          SyncFileJob.perform_now(file)
        }.to raise_error(NoMethodError)
      end
    end
  end

  describe "job enqueuing" do
    let(:file) { { "filename" => "files/document.pdf", "status" => "added" } }

    it "enqueues with the default queue" do
      expect {
        SyncFileJob.perform_later(file)
      }.to have_enqueued_job(SyncFileJob)
             .with(file)
             .on_queue("default")
    end
  end
end
