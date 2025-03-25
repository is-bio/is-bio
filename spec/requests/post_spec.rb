require "rails_helper"

RSpec.describe PostsController, type: :request do
  let!(:post) { create(:post, title: "This is the Post Title") }
  let!(:post_about) { create(:post, permalink: "/about", title: "About Me") }

  it "GET /index" do
    get "/"
    expect(response).to render_template(:index)
    expect(response.body).to include("Next")

    get "/posts"
    expect(response).to render_template(:index)
  end

  describe "GET #show" do
    it "render" do
      get "/this-is-the-post-title-#{post.id}"
      expect(response).to render_template(:show)
      expect(response.body).to include(post.title)
    end

    it "redirect to canonical URL" do
      get "/non-canonical-path-#{post.id}"
      expect(response).to redirect_to("/this-is-the-post-title-#{post.id}")
    end
  end

  describe "GET #about" do
    context "when about page exists" do
      it "renders the about page" do
        get "/about"
        expect(response).to render_template(:about)
        expect(response.body).to include("About Me")
        expect(response.body).to include(post_about.content) if post_about.content.present?
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
