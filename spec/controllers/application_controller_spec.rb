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

  let(:locale) { Locale.find_by(key: I18n.default_locale) || create(:locale, key: I18n.default_locale) }

  describe '#default_locale' do
    it 'returns the locale object for the default locale' do
      allow(Locale).to receive(:find_by).with(key: I18n.default_locale).and_return(locale)
      expect(subject.default_locale).to eq(locale)
    end

    it 'caches the locale object' do
      allow(Locale).to receive(:find_by).once.with(key: I18n.default_locale).and_return(locale)
      subject.default_locale
      expect(subject.default_locale).to eq(locale)
    end
  end
end
