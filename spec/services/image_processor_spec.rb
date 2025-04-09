require "rails_helper"

RSpec.describe ImageProcessor, type: :service do
  describe '.generate_thumbnail' do
    let(:source_path) { '/tmp/test_source_image.jpg' }
    let(:target_path) { '/tmp/test_thumbnail.jpg' }
    let(:mock_image) { instance_double(MiniMagick::Image) }

    before do
      allow(File).to receive(:exist?).with(source_path).and_return(true)
      allow(File).to receive(:directory?).and_return(true)
      allow(FileUtils).to receive(:mkdir_p)
      allow(MiniMagick::Image).to receive(:open).with(source_path).and_return(mock_image)
    end

    context 'with JPEG images' do
      before do
        allow(File).to receive(:extname).with(source_path).and_return('.jpg')
      end

      it 'generates a thumbnail with correct dimensions' do
        expect(mock_image).to receive(:resize).with("300x")
        expect(mock_image).to receive(:format).with("jpg")
        expect(mock_image).to receive(:quality).with(80)
        expect(mock_image).to receive(:write).with(target_path)

        result = ImageProcessor.generate_thumbnail(source_path, target_path)
        expect(result).to be true
      end

      it 'handles errors gracefully' do
        allow(mock_image).to receive(:resize).and_raise(MiniMagick::Error.new("Test error"))
        expect(Rails.logger).to receive(:error).with(/MiniMagick error/)

        result = ImageProcessor.generate_thumbnail(source_path, target_path)
        expect(result).to be false
      end
    end

    context 'with PNG images' do
      before do
        allow(File).to receive(:extname).with(source_path).and_return('.png')
      end

      it 'uses the png format with compression' do
        expect(mock_image).to receive(:resize).with("300x")
        expect(mock_image).to receive(:format).with("png")
        expect(mock_image).to receive(:quality).with(90)
        expect(mock_image).to receive(:write).with(target_path)

        ImageProcessor.generate_thumbnail(source_path, target_path)
      end
    end

    context 'with GIF images' do
      before do
        allow(File).to receive(:extname).with(source_path).and_return('.gif')
      end

      it 'uses GIF format' do
        expect(mock_image).to receive(:resize).with("300x")
        expect(mock_image).to receive(:format).with("gif")
        expect(mock_image).to receive(:write).with(target_path)

        ImageProcessor.generate_thumbnail(source_path, target_path)
      end
    end

    context 'with other image formats' do
      before do
        allow(File).to receive(:extname).with(source_path).and_return('.webp')
      end

      it 'defaults to JPEG format' do
        expect(mock_image).to receive(:resize).with("300x")
        expect(mock_image).to receive(:format).with("jpg")
        expect(mock_image).to receive(:quality).with(80)
        expect(mock_image).to receive(:write).with(target_path)

        ImageProcessor.generate_thumbnail(source_path, target_path)
      end
    end

    context 'with custom width' do
      it 'uses the provided width' do
        allow(File).to receive(:extname).with(source_path).and_return('.jpg')
        custom_width = 500

        expect(mock_image).to receive(:resize).with("#{custom_width}x")
        expect(mock_image).to receive(:format).with("jpg")
        expect(mock_image).to receive(:quality).with(80)
        expect(mock_image).to receive(:write).with(target_path)

        ImageProcessor.generate_thumbnail(source_path, target_path, custom_width)
      end
    end

    context 'when source file does not exist' do
      before do
        allow(File).to receive(:exist?).with(source_path).and_return(false)
      end

      it 'raises an error' do
        expect(Rails.logger).to receive(:error).with("Image not found: #{source_path}")

        expect {
          ImageProcessor.generate_thumbnail(source_path, target_path)
        }.to raise_error(RuntimeError, "Source image file not found at #{source_path}")
      end
    end

    describe '.valid_image?' do
      it 'returns true for valid image extensions' do
        expect(ImageProcessor.valid_image?('test.jpg')).to be true
        expect(ImageProcessor.valid_image?('test.jpeg')).to be true
        expect(ImageProcessor.valid_image?('test.png')).to be true
        expect(ImageProcessor.valid_image?('test.gif')).to be true
      end

      it 'returns false for invalid extensions' do
        expect(ImageProcessor.valid_image?('test.pdf')).to be false
        expect(ImageProcessor.valid_image?('test.txt')).to be false
        expect(ImageProcessor.valid_image?('test')).to be false
      end

      it 'returns false for nil or blank filenames' do
        expect(ImageProcessor.valid_image?(nil)).to be false
        expect(ImageProcessor.valid_image?('')).to be false
      end

      it 'handles uppercase extensions' do
        expect(ImageProcessor.valid_image?('test.JPG')).to be true
        expect(ImageProcessor.valid_image?('test.PNG')).to be true
      end
    end
  end
end
