require "rails_helper"

RSpec.describe PostsController, type: :request do
  let!(:post) { create(:post, title: "This is the Post Title", permalink: "/") }
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
      let(:locale) { Locale.find_by(key: 'es-ES') || create(:locale, key: 'es-ES', english_name: 'Spanish', name: 'Español') }

      it "displays original content when no translation exists" do
        original_locale = I18n.locale
        I18n.locale = :'es-ES'

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

        original_locale = I18n.locale
        I18n.locale = :'es-ES'

        begin
          allow_any_instance_of(Post).to receive(:current_translation).and_return(translation)

          get "/blog/this-is-the-post-title-#{post.id2}"

          expect(response).to render_template(:show)
          expect(response.body).to include("Título traducido")
          expect(response.body).to include("Contenido traducido")
          expect(response.body).not_to include(post.title)
        ensure
          I18n.locale = original_locale
        end
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
end
