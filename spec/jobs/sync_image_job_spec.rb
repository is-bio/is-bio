require "rails_helper"

RSpec.describe SyncImageJob, type: :job do
  describe "#perform" do
    let(:github_username) { instance_double(Setting, value: "test-user") }
    let(:response) { instance_double(Faraday::Response, body: "image-data") }
    let(:faraday_connection) { instance_double(Faraday::Connection) }
    let(:file_double) { instance_double(File) }

    before do
      allow(Setting).to receive(:where).with(key: "github_username").and_return(double(take: github_username))
      allow(Faraday).to receive(:new).and_return(faraday_connection)
      allow(File).to receive(:directory?).and_return(false)
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:exist?).and_return(false)
    end

    context "with image files" do
      context "when status is 'added'" do
        let(:file) { { "filename" => "images/test.jpg", "status" => "added" } }

        it "downloads and saves the image" do
          expect(faraday_connection).to receive(:get)
                                          .with("https://raw.githubusercontent.com/test-user/markdown-blog/main/images/test.jpg")
                                          .and_return(response)

          expect(File).to receive(:open).with(Rails.root.join("public/images/test.jpg").to_s, "wb").and_yield(file_double)
          expect(file_double).to receive(:write).with("image-data")

          SyncImageJob.perform_now(file)
        end
      end

      context "when status is 'modified'" do
        let(:file) { { "filename" => "images/test.png", "status" => "modified" } }

        it "downloads and replaces the image" do
          expect(faraday_connection).to receive(:get)
                                          .with("https://raw.githubusercontent.com/test-user/markdown-blog/main/images/test.png")
                                          .and_return(response)

          expect(File).to receive(:open).with(Rails.root.join("public/images/test.png").to_s, "wb").and_yield(file_double)
          expect(file_double).to receive(:write).with("image-data")

          SyncImageJob.perform_now(file)
        end
      end

      context "when status is 'removed'" do
        let(:file) { { "filename" => "assets/images/logo.jpg", "status" => "removed" } }
        let(:target_file) { Rails.root.join("public/assets/images/logo.jpg").to_s }
        let(:thumbnail_file) { Rails.root.join("public/assets/images/logo_thumb.jpg").to_s }

        before do
          allow(File).to receive(:exist?).with(target_file).and_return(true)
          allow(File).to receive(:exist?).with(thumbnail_file).and_return(true)
        end

        it "removes image and its thumbnail" do
          expect(File).to receive(:delete).with(target_file)
          expect(File).to receive(:delete).with(thumbnail_file)
          SyncImageJob.perform_now(file)
        end

        it "doesn't try to download the image" do
          allow(File).to receive(:delete)
          expect(faraday_connection).not_to receive(:get)
          SyncImageJob.perform_now(file)
        end
      end

      context "when status is 'renamed'" do
        context "when renamed from image to non-image" do
          let(:file) { { "filename" => "docs/readme.txt", "status" => "renamed", "previous_filename" => "images/logo.png" } }
          let(:previous_file_path) { Rails.root.join("public/images/logo.png").to_s }
          let(:previous_thumb_path) { Rails.root.join("public/images/logo_thumb.png").to_s }

          before do
            allow(File).to receive(:exist?).with(previous_file_path).and_return(true)
            allow(File).to receive(:exist?).with(previous_thumb_path).and_return(true)
          end

          it "removes the previous image and its thumbnail" do
            expect(File).to receive(:delete).with(previous_file_path)
            expect(File).to receive(:delete).with(previous_thumb_path)
            SyncImageJob.perform_now(file)
          end

          it "doesn't download or save any new file" do
            allow(File).to receive(:delete)
            expect(faraday_connection).not_to receive(:get)
            expect(File).not_to receive(:open)
            SyncImageJob.perform_now(file)
          end
        end

        context "when renamed from one valid image path to another" do
          let(:file) { { "filename" => "new/path/image.jpg", "status" => "renamed", "previous_filename" => "old/path/image.jpg" } }

          before do
            allow(Directory).to receive(:images?).with("old/path/image.jpg").and_return(true)
            allow(Directory).to receive(:images?).with("new/path/image.jpg").and_return(true)
          end

          it "downloads and saves the image to the new location" do
            expect(faraday_connection).to receive(:get)
                                            .with("https://raw.githubusercontent.com/test-user/markdown-blog/main/new/path/image.jpg")
                                            .and_return(response)

            expect(File).to receive(:open).with(Rails.root.join("public/new/path/image.jpg").to_s, "wb").and_yield(file_double)
            expect(file_double).to receive(:write).with("image-data")

            SyncImageJob.perform_now(file)
          end
        end

        context "when moved out of images directory" do
          let(:file) { { "filename" => "assets/file.jpg", "status" => "renamed", "previous_filename" => "images/file.jpg" } }

          before do
            allow(Directory).to receive(:images?).with("images/file.jpg").and_return(true)
            allow(Directory).to receive(:images?).with("assets/file.jpg").and_return(false)
          end

          it "removes the old image and doesn't download a new one" do
            expect(File).to receive(:delete).with(Rails.root.join("public/images/file.jpg").to_s) if File.exist?(Rails.root.join("public/images/file.jpg").to_s)
            expect(File).not_to receive(:open)

            SyncImageJob.perform_now(file)
          end
        end
      end
    end

    context "with non-image files" do
      let(:file) { { "filename" => "docs/readme.txt", "status" => "added" } }

      it "skips processing" do
        expect(faraday_connection).not_to receive(:get)
        expect(File).not_to receive(:open)

        SyncImageJob.perform_now(file)
      end
    end

    context "with different image extensions" do
      let(:file_jpg) { { "filename" => "images/test.jpg", "status" => "added" } }
      let(:file_png) { { "filename" => "images/test.png", "status" => "added" } }
      let(:file_jpeg) { { "filename" => "images/test.jpeg", "status" => "added" } }
      let(:file_gif) { { "filename" => "images/test.gif", "status" => "added" } }

      it "processes .jpg files" do
        allow(File).to receive(:open).and_yield(file_double)
        allow(file_double).to receive(:write)
        expect(faraday_connection).to receive(:get).with(/.*\/images\/test.jpg/).and_return(response)

        SyncImageJob.perform_now(file_jpg)
      end

      it "processes .png files" do
        allow(File).to receive(:open).and_yield(file_double)
        allow(file_double).to receive(:write)
        expect(faraday_connection).to receive(:get).with(/.*\/images\/test.png/).and_return(response)

        SyncImageJob.perform_now(file_png)
      end

      it "processes .jpeg files" do
        allow(File).to receive(:open).and_yield(file_double)
        allow(file_double).to receive(:write)
        expect(faraday_connection).to receive(:get).with(/.*\/images\/test.jpeg/).and_return(response)

        SyncImageJob.perform_now(file_jpeg)
      end

      it "processes .gif files" do
        allow(File).to receive(:open).and_yield(file_double)
        allow(file_double).to receive(:write)
        expect(faraday_connection).to receive(:get).with(/.*\/images\/test.gif/).and_return(response)

        SyncImageJob.perform_now(file_gif)
      end
    end

    context "with mixed case extensions" do
      let(:file) { { "filename" => "images/test.JPG", "status" => "added" } }

      it "processes files case-insensitively" do
        allow(File).to receive(:open).and_yield(file_double)
        allow(file_double).to receive(:write)
        expect(faraday_connection).to receive(:get).with(/.*\/images\/test.JPG/).and_return(response)

        SyncImageJob.perform_now(file)
      end
    end
  end

  describe "#image_file?" do
    let(:job) { SyncImageJob.new }

    it "identifies .jpg files as images" do
      expect(job.send(:image_file?, "test.jpg")).to be true
    end

    it "identifies .jpeg files as images" do
      expect(job.send(:image_file?, "test.jpeg")).to be true
    end

    it "identifies .png files as images" do
      expect(job.send(:image_file?, "test.png")).to be true
    end

    it "identifies .gif files as images" do
      expect(job.send(:image_file?, "test.gif")).to be true
    end

    it "handles uppercase extensions" do
      expect(job.send(:image_file?, "test.JPG")).to be true
      expect(job.send(:image_file?, "test.PNG")).to be true
    end

    it "rejects non-image files" do
      expect(job.send(:image_file?, "test.txt")).to be false
      expect(job.send(:image_file?, "test.html")).to be false
      expect(job.send(:image_file?, "test")).to be false
      expect(job.send(:image_file?, "test.md")).to be false
    end
  end

  describe "#thumbnail_filename" do
    let(:job) { SyncImageJob.new }

    it "adds _thumb before the extension" do
      expect(job.send(:thumbnail_filename, "/path/to/image.jpg")).to eq("/path/to/image_thumb.jpg")
    end

    it "handles paths with multiple dots" do
      expect(job.send(:thumbnail_filename, "/path/to/image.test.jpg")).to eq("/path/to/image.test_thumb.jpg")
    end

    it "returns the original value for blank input" do
      expect(job.send(:thumbnail_filename, "")).to eq("")
      expect(job.send(:thumbnail_filename, nil)).to eq(nil)
    end
  end

  describe "job enqueuing" do
    let(:file) { { "filename" => "images/test.jpg", "status" => "added" } }

    it "enqueues with the default queue" do
      expect {
        SyncImageJob.perform_later(file)
      }.to have_enqueued_job(SyncImageJob)
             .with(file)
             .on_queue("default")
    end
  end
end
