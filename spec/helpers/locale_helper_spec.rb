require 'rails_helper'

RSpec.describe LocaleHelper, type: :helper do
  let(:default_locale) { I18n.default_locale }

  before do
    def helper.default_locale?
      I18n.locale == I18n.default_locale
    end
  end

  describe '#localed' do
    context 'when in default locale' do
      before do
        allow(helper).to receive(:default_locale?).and_return(true)
      end

      it 'returns the path unchanged' do
        expect(helper.localed('/about')).to eq('/about')
        expect(helper.localed('/contact')).to eq('/contact')
      end

      it 'handles empty path' do
        expect(helper.localed('')).to eq('')
      end
    end

    context 'when in non-default locale' do
      before do
        allow(helper).to receive(:default_locale?).and_return(false)
        allow(I18n).to receive(:locale).and_return(:fr)
      end

      it 'prepends the locale to the path' do
        expect(helper.localed('/about')).to eq('/fr/about')
        expect(helper.localed('/contact')).to eq('/fr/contact')
      end

      it 'handles root path' do
        expect(helper.localed('/')).to eq('/fr/')
      end

      it 'handles empty path' do
        expect(helper.localed('')).to eq('/fr')
        expect(helper.localed(nil)).to eq('/fr')
      end

      context 'with query parameters' do
        it 'preserves query parameters' do
          expect(helper.localed('/about?foo=bar')).to eq('/fr/about?foo=bar')
        end
      end
    end
  end

  describe '#locale_switcher' do
    let(:current_locale) { Locale.new(id: 1, key: 'en', name: 'English') }
    let(:other_locale1) { Locale.new(id: 2, key: 'fr', name: 'Français') }
    let(:other_locale2) { Locale.new(id: 3, key: 'es', name: 'Español') }

    before do
      allow(Locale).to receive(:available_except_current).and_return([ other_locale1, other_locale2 ])
      allow(helper).to receive(:localed_link).with(other_locale1).and_return(%Q(<a href="/fr" class="nav-link">Français</a>).html_safe)
      allow(helper).to receive(:localed_link).with(other_locale2).and_return(%Q(<a href="/es" class="nav-link">Español</a>).html_safe)
    end

    it 'generates a list item for each available locale except current' do
      result = helper.locale_switcher
      expect(result).to have_css('li.nav-item', count: 2)
    end

    it 'includes correct IDs for each locale item' do
      result = helper.locale_switcher
      expect(result).to have_css('li#locale_2')
      expect(result).to have_css('li#locale_3')
    end

    it 'includes the localized links for each locale' do
      result = helper.locale_switcher
      puts result.inspect
      expect(result).to have_css('li#locale_2.nav-item a.nav-link[href="/fr"]', text: 'Français')
      expect(result).to have_css('li#locale_3.nav-item a.nav-link[href="/es"]', text: 'Español')
    end

    it 'returns HTML safe content' do
      expect(helper.locale_switcher).to be_html_safe
    end

    context 'when there are no other locales available' do
      before do
        allow(Locale).to receive(:available_except_current).and_return([])
      end

      it 'returns empty content' do
        expect(helper.locale_switcher).to eq(''.html_safe)
      end
    end
  end

  describe '#localed_link' do
    context 'when linking to the default locale' do
      let(:locale) { double(key: default_locale.to_s, name: 'English') }

      it 'generates a link without a locale prefix' do
        allow(helper).to receive(:url_for).and_return('/path')
        expect(helper).to receive(:url_for).with(locale: nil)
        helper.localed_link(locale)
      end

      it 'generates the correct HTML structure' do
        allow(helper).to receive(:url_for).and_return('/path')
        result = helper.localed_link(locale)
        expect(result).to have_css('a.nav-link i.fa-language.fa-fw.me-2')
        expect(result).to include('English')
      end
    end

    context 'when linking to a non-default locale' do
      let(:locale) { double(key: 'fr', name: 'Français') }

      it 'generates a link with the locale prefix' do
        allow(helper).to receive(:url_for).and_return("/fr/path")
        expect(helper).to receive(:url_for).with(locale: "fr")
        helper.localed_link(locale)
      end

      it 'generates the correct HTML structure' do
        allow(helper).to receive(:url_for).and_return("/fr/path")
        result = helper.localed_link(locale)
        expect(result).to have_css('a.nav-link i.fa-language.fa-fw.me-2')
        expect(result).to include('Français')
      end
    end
  end
end
