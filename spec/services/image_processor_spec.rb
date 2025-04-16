require "rails_helper"

RSpec.describe ImageProcessor, type: :service do
  describe '.generate_thumbnail' do
    let(:source_path) { '/tmp/test_source_image.jpg' }
    let(:target_path) { '/tmp/test_thumbnail.jpg' }
    let(:mock_image) { double('MiniMagick::Image') }

    before do
      allow(File).to receive(:exist?).with(source_path).and_return(true)
      allow(File).to receive(:directory?).and_return(true)
      allow(FileUtils).to receive(:mkdir_p)
      allow(MiniMagick::Image).to receive(:open).with(source_path).and_return(mock_image)
      allow(mock_image).to receive(:resize).and_return(mock_image)
      allow(mock_image).to receive(:format).and_return(mock_image)
      allow(mock_image).to receive(:quality).and_return(mock_image)
      allow(mock_image).to receive(:write)
      allow(mock_image).to receive(:gravity).and_return(mock_image)
      allow(mock_image).to receive(:extent).and_return(mock_image)
    end

    context 'with JPEG images' do
      before do
        allow(File).to receive(:extname).with(source_path).and_return('.jpg')
      end

      it 'generates a thumbnail with correct dimensions' do
        expect(mock_image).to receive(:resize).with("300x300^").and_return(mock_image)
        expect(mock_image).to receive(:gravity).with("center").and_return(mock_image)
        expect(mock_image).to receive(:extent).with("300x300").and_return(mock_image)
        expect(mock_image).to receive(:write).with(target_path)

        result = ImageProcessor.generate_thumbnail(source_path, target_path)
        expect(result).to be true
      end

      it 'handles errors gracefully' do
        error = MiniMagick::Error.new("Test error")
        allow(error).to receive(:backtrace).and_return(["line 1", "line 2"])
        allow(mock_image).to receive(:resize).and_raise(error)

        expect(Rails.logger).to receive(:error).with(/MiniMagick error generating thumbnail: Test error/)
        expect(Rails.logger).to receive(:error).with("line 1\nline 2")

        result = ImageProcessor.generate_thumbnail(source_path, target_path)
        expect(result).to be false
      end
    end

    context 'with PNG images' do
      before do
        allow(File).to receive(:extname).with(source_path).and_return('.png')
      end

      it 'uses the png format with compression' do
        expect(mock_image).to receive(:resize).with("300x300^").and_return(mock_image)
        expect(mock_image).to receive(:gravity).with("center").and_return(mock_image)
        expect(mock_image).to receive(:extent).with("300x300").and_return(mock_image)
        expect(mock_image).to receive(:write).with(target_path)

        ImageProcessor.generate_thumbnail(source_path, target_path)
      end
    end

    context 'with GIF images' do
      before do
        allow(File).to receive(:extname).with(source_path).and_return('.gif')
      end

      it 'uses GIF format' do
        expect(mock_image).to receive(:format).with("gif").and_return(mock_image)
        expect(mock_image).to receive(:write).with(target_path)

        ImageProcessor.generate_thumbnail(source_path, target_path)
      end
    end

    context 'with other image formats' do
      before do
        allow(File).to receive(:extname).with(source_path).and_return('.webp')
      end

      it 'defaults to JPEG format' do
        expect(mock_image).to receive(:resize).with("300x300^").and_return(mock_image)
        expect(mock_image).to receive(:gravity).with("center").and_return(mock_image)
        expect(mock_image).to receive(:extent).with("300x300").and_return(mock_image)
        expect(mock_image).to receive(:write).with(target_path)

        ImageProcessor.generate_thumbnail(source_path, target_path)
      end
    end

    context 'with custom width' do
      it 'uses the provided width' do
        allow(File).to receive(:extname).with(source_path).and_return('.jpg')
        custom_width = 500

        expect(mock_image).to receive(:resize).with("#{custom_width}x#{custom_width}^").and_return(mock_image)
        expect(mock_image).to receive(:gravity).with("center").and_return(mock_image)
        expect(mock_image).to receive(:extent).with("#{custom_width}x#{custom_width}").and_return(mock_image)
        expect(mock_image).to receive(:write).with(target_path)

        ImageProcessor.generate_thumbnail(source_path, target_path, custom_width)
      end
    end

    context 'when source file does not exist' do
      before do
        allow(File).to receive(:exist?).with(source_path).and_return(false)
      end

      it 'raises an error' do
        expect(Rails.logger).to receive(:error).with("==== Image not found: #{source_path}")

        expect {
          ImageProcessor.generate_thumbnail(source_path, target_path)
        }.to raise_error(RuntimeError, "Source image file not found at #{source_path}")
      end
    end
  end
end
