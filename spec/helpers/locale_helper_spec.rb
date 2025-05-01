require 'rails_helper'

RSpec.describe LocaleHelper, type: :helper do
  before(:all) do
    Subdomain.delete_all
    Locale.delete_all
  end

  # Define the default_locale method for the test context
  helper do
    def default_locale
      Locale.find_by(key: 'en') ||
        create(:locale, :english, key: "en", english_name: "English_#{SecureRandom.hex(4)}", name: "English_#{SecureRandom.hex(4)}")
    end
  end

  let(:english_locale) do
    Locale.find_by(key: 'en') ||
      create(:locale, :english, key: "en", english_name: "English_#{SecureRandom.hex(4)}", name: "English_#{SecureRandom.hex(4)}")
  end

  let(:french_locale) do
    Locale.find_by(key: 'fr') ||
      create(:locale_with_key, locale_key: 'fr', locale_english_name: "French_#{SecureRandom.hex(4)}", locale_name: "Français_#{SecureRandom.hex(4)}")
  end

  let(:german_locale) do
    Locale.find_by(key: 'de') ||
      create(:locale_with_key, locale_key: 'de', locale_english_name: "German_#{SecureRandom.hex(4)}", locale_name: "Deutsch_#{SecureRandom.hex(4)}")
  end

  before do
    english_locale
    french_locale
    german_locale
  end

  describe "#locale_switcher" do
    before do
      I18n.locale = :en
      allow(Locale).to receive(:available_except_current).and_return([ french_locale ])
      allow(helper).to receive(:locale_url_for).with(french_locale).and_return('http://fr.example.com')
    end

    it "generates links for available locales" do
      html = helper.locale_switcher
      expect(html).to have_selector('li.nav-item a.nav-link[href="http://fr.example.com"]', text: french_locale.name)
    end

    it "includes language icon" do
      html = helper.locale_switcher
      expect(html).to have_selector('i.fa-language')
    end

    context "with multiple locales" do
      before do
        spanish_locale = Locale.find_by(key: 'es') ||
          create(:locale_with_key, locale_key: 'es', locale_name: "Español_#{SecureRandom.hex(4)}", locale_english_name: "Spanish_#{SecureRandom.hex(4)}")

        allow(Locale).to receive(:available_except_current).and_return([ french_locale, spanish_locale ])

        allow(helper).to receive(:locale_url_for).with(spanish_locale).and_return('http://es.example.com')
      end

      it "generates multiple links" do
        html = helper.locale_switcher
        expect(html).to have_selector('li.nav-item', count: 2)
      end
    end
  end

  describe '#locale_url_for' do
    let(:default_locale) { Locale.find_by(key: I18n.default_locale) || create(:locale, key: I18n.default_locale) }

    it 'returns the original URL if no locale is provided' do
      expect(helper.locale_url_for(nil)).to eq(request.original_url)
    end
  end

  describe '#locale_switcher' do
    let(:locale) { Locale.find_by(key: "en") || create(:locale, key: 'en') }

    it 'generates HTML for available locales' do
      allow(Locale).to receive(:available_except_current).and_return([ locale ])
      html = helper.locale_switcher
      expect(html).to include(locale.name)
      expect(html).to include('fa-language')
    end
  end
end
