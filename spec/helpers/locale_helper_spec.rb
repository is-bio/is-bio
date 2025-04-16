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
    Subdomain.where(value: %w[www fr]).delete_all

    create(:subdomain, :www, locale: english_locale) unless Subdomain.find_by(value: 'www')
    create(:subdomain, value: 'fr', locale: french_locale) unless Subdomain.find_by(value: 'fr')

    english_locale
    french_locale
    german_locale
  end

  describe "#locale_url_for" do
    context "with subdomain in current URL" do
      before do
        allow(helper).to receive(:request).and_return(
          double(
            "Request",
            original_url: "https://www.example.com/posts/1",
            subdomains: [ "www" ],
            host: 'www.example.com'
          )
        )
      end

      it "replaces existing subdomain" do
        expect(helper.locale_url_for(french_locale)).to eq('https://fr.example.com/posts/1')
      end
    end

    context "without subdomain in current URL" do
      before do
        allow(helper).to receive(:request).and_return(
          double("Request",
                 original_url: 'http://example.com/about',
                 subdomains: [],
                 host: 'example.com'
          )
        )
      end

      it "adds new subdomain" do
        expect(helper.locale_url_for(french_locale)).to eq('http://fr.example.com/about')
      end
    end

    context "with query parameters" do
      before do
        allow(helper).to receive(:request).and_return(
          double("Request",
                 original_url: 'https://www.example.com/search?q=rails',
                 subdomains: [ 'www' ],
                 host: 'www.example.com'
          )
        )
      end

      it "preserves query params" do
        expect(helper.locale_url_for(french_locale)).to eq('https://fr.example.com/search?q=rails')
      end
    end

    context "with locale having no subdomain" do
      before do
        Subdomain.where(locale_id: german_locale.id).delete_all
      end

      it "returns original URL" do
        original = 'http://www.example.com/posts'
        allow(helper).to receive(:request).and_return(
          double("Request", original_url: original, subdomains: [ 'www' ], host: 'www.example.com')
        )
        expect(helper.locale_url_for(german_locale)).to eq(original)
      end
    end

    context "with nil locale" do
      it "returns original URL" do
        original = 'http://www.example.com/posts'
        allow(helper).to receive(:request).and_return(
          double("Request", original_url: original, subdomains: [ 'www' ], host: 'www.example.com')
        )
        expect(helper.locale_url_for(nil)).to eq(original)
      end
    end
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

        Subdomain.where(value: 'es').delete_all
        create(:subdomain, value: 'es', locale: spanish_locale)

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
    let(:subdomain) { Subdomain.find_by(locale: default_locale) || create(:subdomain, locale: default_locale) }

    it 'returns the original URL if no locale is provided' do
      expect(helper.locale_url_for(nil)).to eq(request.original_url)
    end

    it 'removes the default locale subdomain from URL' do
      allow(request).to receive(:subdomains).and_return([ subdomain.value ])
      expect(helper.locale_url_for(default_locale)).not_to include("#{subdomain.value}.")
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
