require "rails_helper"

RSpec.describe CategoriesController, type: :request do
  let(:category) { create(:category, name: "Test-Category") }
  let!(:post1) { create(:post, title: "First Post", category: category) }
  let!(:post2) { create(:post, title: "Second Post", category: category) }

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
    end

    context "when category does not exist in drafts" do
      before do
        allow(Category).to receive(:find_by_name_from_drafts).with("non-existent").and_return(nil)
      end

      it "returns a not found status" do
        get "/drafts/non-existent"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
