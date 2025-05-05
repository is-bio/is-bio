require "rails_helper"

RSpec.describe PostsController, type: :request do
  let!(:post) { create(:post, title: "This is the Post Title", permalink: "/") }
  let!(:post2) { create(:post, title: "This is the Post Title 2", permalink: "/") }
  let!(:post_about) { create(:post, permalink: "/about", title: "About Me") }

  it "GET /index" do
    get "/"
    expect(response).to render_template(:index)
    expect(response.body).to include("Next")

    get '/posts'
    expect(response).to render_template(:index)
  end

  describe "GET #show" do
    it "renders the post" do
      get "/blog/this-is-the-post-title-#{post.id2}"
      expect(response).to render_template(:show)
      expect(response.body).to include(post.title)
    end

    it "redirects to canonical URL if permalink doesn't match" do
      get "/blog/non-canonical-path-#{post.id2}"
      expect(response).to redirect_to("/blog/this-is-the-post-title-#{post.id2}")
    end

    context "when viewing in a non-default language" do
      let(:locale) { Locale.find_by(key: 'es') || create(:locale, key: 'es', english_name: 'Spanish', name: 'Español') }

      it "displays original content when no translation exists" do
        original_locale = I18n.locale
        I18n.available_locales = [ :en, :es ]
        I18n.locale = :es

        post.update!(content: "Sample content for testing")

        begin
          allow_any_instance_of(Post).to receive(:current_translation).and_return(nil)

          get "/blog/this-is-the-post-title-#{post.id2}"

          expect(response).to render_template(:show)
          expect(response.body).to include(post.title)
          expect(response.body).to include("Sample content for testing")
        ensure
          I18n.locale = original_locale
        end
      end

      it "displays translated content when translation exists" do
        translation = create(
          :translation,
          post: post,
          locale: locale,
          title: "Título traducido",
          content: "Contenido traducido"
        )

        allow(I18n).to receive(:locale).and_return(:es)
        allow_any_instance_of(Post).to receive(:current_translation).and_return(translation)

        get "/blog/this-is-the-post-title-#{post.id2}"

        expect(response).to render_template(:show)
        expect(response.body).to include("Título traducido")
        expect(response.body).to include("Contenido traducido")
        expect(response.body).not_to include(post.title)
        expect(response.body).not_to include("noindex, nofollow")
      end

      it "displays no_title and no_content messages when no translation exists" do
        allow(I18n).to receive(:locale).and_return(:es)
        allow_any_instance_of(Post).to receive(:current_translation).and_return(nil)

        get "/blog/this-is-the-post-title-#{post.id2}"

        expect(response).to render_template(:show)
        expect(response.body).to include("noindex, nofollow")
        expect(response.body).to include("No Title").or include("Sin título")
        expect(response.body).to include("es")
        expect(response.body).not_to include(post.title)
      end

      it "includes alternate language links only for available translations" do
        I18n.available_locales = [ :en, :es, :fr, :de, :'zh-TW' ]
        en_locale = Locale.find_by(key: 'en') || create(:locale, :english)
        es_locale = Locale.find_by(key: 'es') || create(:locale, key: 'es', english_name: "Spanish_#{SecureRandom.hex(4)}", name: "Español_#{SecureRandom.hex(4)}")
        fr_locale = Locale.find_by(key: 'fr') || create(:locale, key: 'fr', english_name: "French_#{SecureRandom.hex(4)}", name: "Français_#{SecureRandom.hex(4)}")
        de_locale = Locale.find_by(key: 'de') || create(:locale, key: 'de', english_name: "German_#{SecureRandom.hex(4)}", name: "Deutsch_#{SecureRandom.hex(4)}")
        tw_locale = Locale.find_by(key: 'zh-TW') || create(:locale, key: 'zh-TW', english_name: "Traditional Chinese_#{SecureRandom.hex(4)}", name: "正體中文_#{SecureRandom.hex(4)}")

        # Create translations for different languages
        es_translation = create(:translation, post: post2, locale: es_locale, title: "Título en español")
        fr_translation = create(:translation, post: post2, locale: fr_locale, title: "Titre en français")
        tw_translation = create(:translation, post: post2, locale: tw_locale, title: "正體標題")

        get "/blog/this-is-the-post-title-2-#{post2.id2}"

        # Rails sets the default test host to www.example.com for consistency and isolation.
        # https://github.com/rails/rails/blob/main/actionpack/lib/action_dispatch/testing/integration.rb?spm=a2ty_o01.29997173.0.0.467dc921PZwxwr#L92
        expect(response.body).to include('rel="canonical" href="https://www.example.com/blog/this-is-the-post-title-2-')
        expect(response.body).to include('hreflang="en" href="/blog/this-is-the-post-title-2-')
        expect(response.body).to include('hreflang="es" href="/es/blog/this-is-the-post-title-2-')
        expect(response.body).to include('hreflang="fr" href="/fr/blog/this-is-the-post-title-2-')
        expect(response.body).to include('hreflang="zh-tw" href="/zh-tw/blog/this-is-the-post-title-2-')
        expect(response.body).not_to include('hreflang="de"')
        expect(response.body).to include('hreflang="x-default" href="/blog/this-is-the-post-title-2-')
      end
    end
  end

  describe "GET #about" do
    context "when about page exists" do
      it "renders the about page" do
        get "/about"
        expect(response).to render_template(:about)
        expect(response.body).to include("About Me")
        expect(response.body).to include("Sample Post") if post_about.content.present?
      end
    end

    context "when about page does not exist" do
      before do
        post_about.destroy!
      end

      it "renders default content" do
        get "/about"
        expect(response).to render_template(:about)
        expect(response.body).to include("There is currently no content to display")
      end
    end
  end

  describe "GET about" do
    context "when about page does not exist" do
      before do
        allow(Post).to receive(:where).with(permalink: "/about").and_return([])
      end

      it "creates a default post with instructions" do
        get "/about"
        expect(assigns(:post)).to be_a_new(Post)
        expect(assigns(:post).content).to include("There is currently no content to display")
        expect(assigns(:post).content).to include("/path/to/markdown-blog/published/about.md")
      end
    end

    context "when about page exists" do
      let(:about_post) { create(:post, permalink: "/about") }

      before do
        allow(Post).to receive(:where).with(permalink: "/about").and_return([ about_post ])
        allow(about_post).to receive(:translated!)
      end

      it "uses the existing post and marks it as translated" do
        get "/about"
        expect(assigns(:post)).to eq(about_post)
        expect(about_post).to have_received(:translated!)
      end
    end
  end

  describe "GET hire" do
    context "when hire page does not exist" do
      before do
        allow(Post).to receive(:where).with(permalink: "/hire").and_return([])
      end

      it "creates a default post with instructions" do
        get "/hire"
        expect(assigns(:post)).to be_a_new(Post)
        expect(assigns(:post).content).to include("There is currently no content to display")
        expect(assigns(:post).content).to include("/path/to/markdown-blog/published/hire.md")
        expect(response).to render_template("about")
      end
    end

    context "when hire page exists" do
      let(:hire_post) { create(:post, permalink: "/hire") }

      before do
        allow(Post).to receive(:where).with(permalink: "/hire").and_return([ hire_post ])
        allow(hire_post).to receive(:translated!)
      end

      it "uses the existing post, marks it as translated, and renders the about template" do
        get "/hire"
        expect(assigns(:post)).to eq(hire_post)
        expect(hire_post).to have_received(:translated!)
        expect(response).to render_template("about")
      end
    end
  end
end
