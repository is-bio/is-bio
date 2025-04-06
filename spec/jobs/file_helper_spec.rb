require "rails_helper"

RSpec.describe FileHelper do
  # Create a test class that includes the module for testing
  let(:dummy_class) { Class.new { include FileHelper } }
  let(:helper) { dummy_class.new }

  describe "#ensure_directory_exists" do
    context "when directory does not exist" do
      before do
        allow(File).to receive(:dirname).and_return("/path/to/directory")
        allow(File).to receive(:directory?).and_return(false)
        allow(FileUtils).to receive(:mkdir_p)
      end

      it "creates the directory" do
        expect(FileUtils).to receive(:mkdir_p).with("/path/to/directory")
        helper.ensure_directory_exists("/path/to/directory/filename.txt")
      end
    end

    context "when directory already exists" do
      before do
        allow(File).to receive(:dirname).and_return("/path/to/directory")
        allow(File).to receive(:directory?).and_return(true)
      end

      it "does not create the directory" do
        expect(FileUtils).not_to receive(:mkdir_p)
        helper.ensure_directory_exists("/path/to/directory/filename.txt")
      end
    end

    context "with nested directories" do
      before do
        allow(File).to receive(:dirname).and_return("/path/to/nested/directory")
        allow(File).to receive(:directory?).and_return(false)
        allow(FileUtils).to receive(:mkdir_p)
      end

      it "creates all required directories" do
        expect(FileUtils).to receive(:mkdir_p).with("/path/to/nested/directory")
        helper.ensure_directory_exists("/path/to/nested/directory/filename.txt")
      end
    end
  end

  describe "#remove_target_file" do
    context "when file exists" do
      before do
        allow(helper).to receive(:target_filename).with("images/test.jpg").and_return("/app/public/images/test.jpg")
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:delete)
      end

      it "deletes the file" do
        expect(File).to receive(:delete).with("/app/public/images/test.jpg")
        helper.remove_target_file("images/test.jpg")
      end
    end

    context "when file does not exist" do
      before do
        allow(helper).to receive(:target_filename).with("images/nonexistent.jpg").and_return("/app/public/images/nonexistent.jpg")
        allow(File).to receive(:exist?).and_return(false)
      end

      it "does not attempt to delete the file" do
        expect(File).not_to receive(:delete)
        helper.remove_target_file("images/nonexistent.jpg")
      end
    end

    context "with different file paths" do
      before do
        allow(helper).to receive(:target_filename).with("documents/file.pdf").and_return("/app/public/documents/file.pdf")
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:delete)
      end

      it "uses the correct file path" do
        expect(File).to receive(:delete).with("/app/public/documents/file.pdf")
        helper.remove_target_file("documents/file.pdf")
      end
    end
  end

  describe "#target_filename" do
    before do
      allow(Rails).to receive(:root).and_return(Pathname.new("/app"))
    end

    context "with a simple filename" do
      it "prepends Rails.root/public to the filename" do
        expect(helper.target_filename("test.jpg")).to eq("/app/public/test.jpg")
      end
    end

    context "with a nested path" do
      it "preserves the directory structure" do
        expect(helper.target_filename("images/photos/vacation.jpg")).to eq("/app/public/images/photos/vacation.jpg")
      end
    end

    context "with a filename that already has a leading slash" do
      it "handles the path correctly" do
        expect(helper.target_filename("/images/logo.png")).to eq("/app/public//images/logo.png")
      end
    end

    context "with an empty filename" do
      it "returns the public directory path" do
        expect(helper.target_filename("")).to eq("/app/public/")
      end
    end

    context "with nil filename" do
      it "returns the public directory path with nil appended" do
        expect(helper.target_filename(nil)).to eq("/app/public/")
      end
    end
  end
end
