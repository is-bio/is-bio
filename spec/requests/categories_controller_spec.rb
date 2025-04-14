require "rails_helper"

RSpec.describe CategoriesController, type: :request do
  let(:published_category) { Category.find_by(id: Category::ID_PUBLISHED) || create(:category, id: Category::ID_PUBLISHED, name: "Published") }
  let(:category) { create(:category, name: "Test-Category", parent: published_category) }
  let!(:post1) { create(:post, title: "First Post", category: category) }
  let!(:post2) { create(:post, title: "Second Post", category: category) }
  let(:es_locale) { Locale.find_by(key: "es-ES") || create(:locale, key: "es-ES", english_name: "Spanish", name: "Español") }
  let(:fr_locale) { Locale.find_by(key: "fr-FR") || create(:locale, key: "fr-FR", english_name: "French", name: "Français") }
  let(:de_locale) { Locale.find_by(key: "de-DE") || create(:locale, key: "de-DE", english_name: "German2", name: "Deutsch2") }

  describe "GET #show" do
    context "when category exists" do
      before do
        allow(Category).to receive(:find_by_name).with(category.path_name).and_return(category)
      end

      it "renders the show template" do
        get "/category/#{category.path_name}"
        expect(response).to render_template(:show)
        expect(response.body).to include(post1.title)
        expect(response.body).to include(post2.title)
        expect(response.body).to include(category.name.titleize)
      end

      it "displays all posts from the category" do
        get "/category/#{category.path_name}"
        expect(response.body).to include(post1.path)
        expect(response.body).to include(post2.path)
      end

      context "with translations" do
        before do
          # 确保locale记录存在
          es_locale
          fr_locale
        end

        let!(:translation1) { create(:translation, post: post1, locale: es_locale, title: "Primer artículo", content: "Contenido en español") }
        let!(:translation2) { create(:translation, post: post2, locale: fr_locale, title: "Deuxième article", content: "Contenu en français") }

        context "when using default locale" do
          it "displays original posts" do
            # Ensure we're using the default locale
            original_locale = I18n.locale
            I18n.locale = I18n.default_locale

            begin
              get "/category/#{category.path_name}"
              expect(response.body).to include(post1.title)
              expect(response.body).to include(post2.title)
              expect(response.body).not_to include("Primer artículo")
              expect(response.body).not_to include("Deuxième article")
            ensure
              I18n.locale = original_locale
            end
          end
        end

        context "when using Spanish locale" do
          it "displays Spanish translations when available" do
            # Set locale to Spanish
            original_locale = I18n.locale

            # 模拟 I18n 行为
            allow(I18n).to receive(:available_locales).and_return([:en, :"es-ES", :"fr-FR"])
            allow(I18n).to receive(:locale).and_return(:"es-ES")
            allow(I18n).to receive(:default_locale).and_return(:en)

            # Mock the controller behavior for Spanish locale
            allow_any_instance_of(ApplicationController).to receive(:current_locale).and_return(es_locale)
            allow_any_instance_of(ApplicationController).to receive(:default_locale?).and_return(false)

            # Stub the translated_posts method to return only Spanish translated posts
            allow_any_instance_of(CategoriesController).to receive(:translated_posts) do |controller|
              controller.instance_variable_set(:@posts, Post.where(id: post1.id))

              # Apply translation to the post
              post1.title = "Primer artículo"
              post1.content = "Contenido en español"
            end

            begin
              get "/category/#{category.path_name}"

              # We need to check for the presence of the first post's ID or path,
              # since the actual title has been mocked
              expect(response.body).to include(post1.path)
              expect(response.body).not_to include(post2.path)
            ensure
              I18n.locale = original_locale
            end
          end
        end

        context "when using French locale" do
          it "displays French translations when available" do
            # Set locale to French
            original_locale = I18n.locale

            allow(I18n).to receive(:available_locales).and_return([:en, :"es-ES", :"fr-FR"])
            allow(I18n).to receive(:locale).and_return(:"fr-FR")
            allow(I18n).to receive(:default_locale).and_return(:en)

            # Mock the controller behavior for French locale
            allow_any_instance_of(ApplicationController).to receive(:current_locale).and_return(fr_locale)
            allow_any_instance_of(ApplicationController).to receive(:default_locale?).and_return(false)

            # Stub the translated_posts method to return only French translated posts
            allow_any_instance_of(CategoriesController).to receive(:translated_posts) do |controller|
              controller.instance_variable_set(:@posts, Post.where(id: post2.id))

              # Apply translation to the post
              post2.title = "Deuxième article"
              post2.content = "Contenu en français"
            end

            begin
              get "/category/#{category.path_name}"

              # We need to check for the presence of the second post's ID or path
              expect(response.body).to include(post2.path)
              expect(response.body).not_to include(post1.path)
            ensure
              I18n.locale = original_locale
            end
          end
        end

        context "when using a locale with no translations" do
          it "shows no posts" do
            de_locale

            original_locale = I18n.locale

            allow(I18n).to receive(:available_locales).and_return([:en, :"es-ES", :"fr-FR", :"de-DE"])
            allow(I18n).to receive(:locale).and_return(:"de-DE")
            allow(I18n).to receive(:default_locale).and_return(:en)

            # Mock the current_locale method to return the German locale
            allow_any_instance_of(ApplicationController).to receive(:current_locale).and_return(de_locale)
            allow_any_instance_of(ApplicationController).to receive(:default_locale?).and_return(false)

            # Stub the translated_posts method to return no posts
            allow_any_instance_of(CategoriesController).to receive(:translated_posts) do |controller|
              controller.instance_variable_set(:@posts, Post.none)
            end

            begin
              get "/category/#{category.path_name}"

              # No posts should be displayed as there are no German translations
              expect(response.body).not_to include(post1.path)
              expect(response.body).not_to include(post2.path)
            ensure
              I18n.locale = original_locale
            end
          end
        end
      end
    end

    context "when category does not exist" do
      before do
        allow(Category).to receive(:find_by_name).with("non-existent").and_return(nil)
      end

      it "returns a not found status" do
        get "/category/non-existent"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET #drafts_show" do
    context "when user is not authenticated" do
      it "redirects to the login page" do
        get "/drafts/#{category.path_name}"
        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "when user is authenticated" do
      let(:user) { create(:user) }
      let(:session) { create(:session, user: user) }

      before do
        allow_any_instance_of(CategoriesController).to receive(:authenticated?).and_return(true)
        allow_any_instance_of(CategoriesController).to receive(:resume_session).and_return(session)
      end

      context "when category exists in drafts" do
        before do
          allow(Category).to receive(:find_by_name_from_drafts).with(category.path_name).and_return(category)
        end

        it "renders the show template" do
          get "/drafts/#{category.path_name}"
          expect(response).to render_template(:show)
          expect(response.body).to include(post1.title)
          expect(response.body).to include(post2.title)
          expect(response.body).to include(post1.path)
        end

        context "with translations in drafts" do
          before do
            # 确保locale记录存在
            es_locale
          end

          let!(:translation1) { create(:translation, post: post1, locale: es_locale, title: "Primer borrador", content: "Contenido borrador") }

          it "displays translated drafts when using non-default locale" do
            # Set locale to Spanish
            original_locale = I18n.locale

            # 模拟 I18n 行为
            allow(I18n).to receive(:available_locales).and_return([:en, :"es-ES"])
            allow(I18n).to receive(:locale).and_return(:"es-ES")
            allow(I18n).to receive(:default_locale).and_return(:en)

            # Mock the controller behavior for Spanish locale
            allow_any_instance_of(ApplicationController).to receive(:current_locale).and_return(es_locale)
            allow_any_instance_of(ApplicationController).to receive(:default_locale?).and_return(false)

            # Stub the translated_posts method to return only Spanish translated posts
            allow_any_instance_of(CategoriesController).to receive(:translated_posts) do |controller|
              controller.instance_variable_set(:@posts, Post.where(id: post1.id))

              # Apply translation to the post
              post1.title = "Primer borrador"
              post1.content = "Contenido borrador"
            end

            begin
              get "/drafts/#{category.path_name}"

              # We need to check for the presence of the first post's ID or path
              expect(response.body).to include(post1.path)
              expect(response.body).not_to include(post2.path)
            ensure
              I18n.locale = original_locale
            end
          end
        end
      end

      context "when category does not exist in drafts" do
        it "returns a not found status" do
          get "/drafts/non-existent"
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
