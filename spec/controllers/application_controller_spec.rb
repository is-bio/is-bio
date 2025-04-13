require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  describe "#raise_404" do
    it "raises a RoutingError with message 'Not Found'" do
      expect {
        controller.send(:raise_404)
      }.to raise_error(ActionController::RoutingError, "Not Found")
    end
  end

  describe "#switch_locale" do
    controller do
      def index
        render plain: "Current locale: #{I18n.locale}"
      end
    end
  end

  describe "#extract_locale_from_subdomain" do
    controller do
      def index
        render plain: "Testing locale extraction"
      end
    end

    context "with hyphenated subdomain" do
      let(:subdomains) { ['en-us'] }
      let(:mock_subdomain) { instance_double(Subdomain, locale: instance_double(Locale, key: 'en')) }

      before do
        allow(request).to receive(:subdomains).and_return(subdomains)
        allow(Subdomain).to receive(:find_by).with(value: subdomains.first).and_return(mock_subdomain)
      end

      it "finds locale with hyphenated value" do
        expect(Subdomain).to receive(:find_by).with(value: 'en-us')
        expect(controller.send(:extract_locale_from_subdomain)).to eq(:en)
      end
    end

    context "with www subdomain" do
      let(:subdomains) { ['www'] }
      let(:mock_subdomain) { instance_double(Subdomain, locale: instance_double(Locale, key: 'en')) }

      before do
        allow(request).to receive(:subdomains).and_return(subdomains)
        allow(Subdomain).to receive(:find_by).with(value: subdomains.first).and_return(mock_subdomain)
      end

      it "maps to configured locale" do
        expect(controller.send(:extract_locale_from_subdomain)).to eq(:en)
      end
    end

    context "with invalid subdomain" do
      let(:subdomains) { ['invalid'] }
      let(:mock_subdomain) { nil }

      before do
        allow(request).to receive(:subdomains).and_return(subdomains)
        allow(Subdomain).to receive(:find_by).with(value: subdomains.first).and_return(mock_subdomain)
      end

      it "returns nil" do
        expect(controller.send(:extract_locale_from_subdomain)).to be_nil
      end
    end

    context "with no subdomains" do
      let(:subdomains) { [] }
      let(:mock_subdomain) { nil }

      before do
        allow(request).to receive(:subdomains).and_return(subdomains)
      end

      it "returns nil" do
        expect(controller.send(:extract_locale_from_subdomain)).to be_nil
      end
    end
  end
end
